#!/bin/bash

set -e

dir="generated"

mkdir -p "$dir"

if [ ! -e "$dir/ca.key" ]; then
    echo "Generating root CA key and certificate"

    touch "$dir/ca.index"

    openssl req -new -out "$dir/ca.csr" -config setup/ca.conf

    openssl rand -hex 16 > "$dir/ca.serial"
    openssl ca -selfsign -in "$dir/ca.csr" -out "$dir/ca.crt" \
        -extensions root-ca_ext -config setup/ca.conf

    openssl x509 -in "$dir/ca.crt" -out "$dir/ca.pem"
    cp "$dir/ca.pem" "$dir/ca.crt"
fi

function createCert {
    user=$1

    if [ ! -e "$dir/$user.key" ]; then
        echo "Generating client certificate for $user"
        openssl genrsa -out "$dir/$user.key" 4096

        openssl req -new -key "$dir/$user.key" -out "$dir/$user.csr" \
            -config "setup/$user.conf"

        openssl x509 -req -in "$dir/$user.csr" -CA "$dir/ca.crt" \
            -CAkey "$dir/ca.key" -CAcreateserial -out "$dir/$user.crt" -days 500
    fi
}

echo ""

createCert vault

if [ -x "$(command -v minikube 2>/dev/null)" ]; then
    set +e
    ssh -i $(minikube ssh-key) docker@$(minikube ip) \
        'su -c "cat /data/vault/ssl/vault.key"' > /dev/null 2>&1
    res=$?
    set -e

    if [[ $res != 0 ]]; then
        echo "Copying vault certificate and key to server"
        minikube ssh 'su -c "mkdir -p /data/vault/ssl"'

        for file in vault.key vault.crt ca.crt; do
            ssh -i $(minikube ssh-key) docker@$(minikube ip) \
                "su -c 'cat > /data/vault/ssl/$file'" < "$dir/$file"
        done
    fi
else
    echo "Please copy the certificates manually to the server"
fi

echo ""

./applyDir.sh haproxy
./applyDir.sh vault

echo ""

createCert "vault-operator"

export VAULT_ADDR="https://vault.cerberus-systems.de"
export VAULT_CACERT="$dir/ca.crt"
export VAULT_CLIENT_CERT="$dir/vault-operator.crt"
export VAULT_CLIENT_KEY="$dir/vault-operator.key"

set +e
vaultKeys=$(vault operator init 2> /dev/null)
res=$?
set -e

if [[ $res == 0 ]]; then
    echo "$vaultKeys" > vault_keys.txt

    echo "Initialized vault - find keys in vault_keys.txt"

    for i in 1 2 3; do
        key=$(echo "$vaultKeys" | grep "Unseal Key $i:" | awk '{print $NF}')

        vault operator unseal "$key" > /dev/null
    done
    echo "Vault unsealed"
fi

token=$(cat vault_keys.txt | grep "Initial Root Token: " | awk '{print $NF}')
export VAULT_TOKEN="$token"

for name in pki_int_outside pki_int_inside; do

    set +e
    vault secrets enable -path="$name" pki 2> /dev/null
    res=$?
    set -e

    if [[ $res == 0 ]]; then
        vault secrets tune -max-lease-ttl=720h "$name"

        vault write "$name/intermediate/generate/internal" \
            common_name="Cerberus Systems Intermediate CA" \
            organization="Cerberus Systems" \
            ttl=43800h -format=json | \
            jq -r .data.csr > "$dir/$name.csr"

        openssl rand -hex 16 > "$dir/ca.serial"

        openssl ca -extensions intermediate-ca_ext -in "$dir/$name.csr" \
                -out "$dir/$name.crt" -days 720 -config setup/ca.conf

        vault write "$name/intermediate/set-signed" certificate="@$dir/$name.crt"
    fi
done
