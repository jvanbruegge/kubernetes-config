#!/bin/bash

dev=true

if [[ ! -z "$1" ]]; then
    dev=false
fi

if [[ $dev ]]; then
    ./startMinikube.sh create
fi

dir="generated"

mkdir -p "$dir"

rm $dir/vault*

cat ~/.ssh/known_hosts | grep -v 192.168.99.100 > ~/.ssh/known_hosts

set -e

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

        if [ -e "setup/$user.ext" ]; then
            openssl x509 -req -in "$dir/$user.csr" -CA "$dir/ca.crt" \
                -CAkey "$dir/ca.key" -CAcreateserial -out "$dir/$user.crt" -days 500 \
                -extfile "setup/$user.ext"
        else
            openssl x509 -req -in "$dir/$user.csr" -CA "$dir/ca.crt" \
                -CAkey "$dir/ca.key" -CAcreateserial -out "$dir/$user.crt" -days 500
        fi
    fi
}

echo ""

createCert vault

function transferVaultCert() {
    ca=$1
    if [[ $dev ]]; then
        echo "Copying vault certificate and key to server"
        minikube ssh 'su -c "mkdir -p /data/vault/ssl"'

        for file in vault.key vault.crt "$ca"; do
            filename="$file"
            if [[ "$file" == "$ca" ]]; then
                filename="ca.crt"
            fi
            ssh -i $(minikube ssh-key) docker@$(minikube ip) \
                "su -c 'cat > /data/vault/ssl/$filename'" < "$dir/$file"
        done
    else
        echo "Please copy the certificates manually to the server"
    fi
}

transferVaultCert ca.crt

echo ""

./applyDir.sh haproxy
./applyDir.sh vault

sleep 5

echo ""
echo "Waiting for vault to start up"

kubectl wait --namespace=vault --for=condition=ready --timeout=3000s pods vault-0

echo ""

createCert "vault-operator"

sleep 10

export VAULT_ADDR="https://vault.cerberus-systems.de"
export VAULT_CACERT="$dir/ca.crt"
export VAULT_CLIENT_CERT="$dir/vault-operator.crt"
export VAULT_CLIENT_KEY="$dir/vault-operator.key"

set +e
vaultKeys=$(vault operator init 2> /dev/null)
res=$?
set -e

function unsealVault() {
    for i in 1 2 3; do
        key=$(cat "vault_keys.txt" | grep "Unseal Key $i:" | awk '{print $NF}')

        vault operator unseal "$key" > /dev/null
    done
    echo "Vault unsealed"
}

if [[ $res == 0 ]]; then
    echo "$vaultKeys" > vault_keys.txt

    echo "Initialized vault - find keys in vault_keys.txt"
fi

unsealVault

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

        # Remove text encoding from file
        openssl x509 -in "$dir/$name.crt" -out "$dir/$name.crt"

        vault write "$name/intermediate/set-signed" certificate="@$dir/$name.crt"

        vault write "$name/roles/get-cert" \
            allowed_domains=cerberus-systems.de,cerberus-systems.com,svc.cluster.local \
            allow_subdomains=true max_ttl=1860h
    fi
done

set +e
kubectl delete secret ca-inside
kubectl delete secret ca-outside
kubectl delete secret root-ca
set -e
kubectl create secret generic ca-inside --from-file="$dir/pki_int_inside.crt"
kubectl create secret generic ca-outside --from-file="$dir/pki_int_outside.crt"
kubectl create secret generic root-ca --from-file="$dir/ca.crt"

function getIntermediateCert() {
    scope=$1
    user=$2
    namespace=$3

    if [[ -z "$namespace" ]]; then
        namespace="default"
    fi

    if [[ "$user" == "*.users" ]]; then
        result=$(vault write "pki_int_$scope/issue/get-cert" -format="json" \
            common_name="$user.cerberus-systems.de")
    else
        result=$(vault write "pki_int_$scope/issue/get-cert" -format="json" \
            common_name="$user.cerberus-systems.de" \
            alt_names="$user.cerberus-systems.com,$user.$namespace.svc.cluster.local")
    fi

    echo "$result" | jq -r '.data.certificate' > "$dir/$user.crt"
    echo "$result" | jq -r '.data.private_key' > "$dir/$user.key"
}

echo "Getting certificate for vault from intermediate CA"
getIntermediateCert outside vault vault
getIntermediateCert outside vault-operator

transferVaultCert pki_int_outside.crt

kubectl delete --namespace=vault statefulsets.apps vault
kubectl wait --namespace=vault --for=delete --timeout=3000s pods vault-0

./applyDir.sh vault
export VAULT_CACERT="$dir/pki_int_outside.crt"
sleep 5

kubectl wait --namespace=vault --for=condition=ready --timeout=3000s pods vault-0

unsealVault

set +e
vault auth enable kubernetes 2> /dev/null
res=$?
set -e

if [[ $res == 0 ]]; then
    echo "Configuring vault kubernetes authentification"

    accountPath="/run/secrets/kubernetes.io/serviceaccount"
    kubeCert=$(kubectl exec --namespace=vault -it vault-0 -- sh -c "cat $accountPath/ca.crt")
    serviceToken=$(kubectl exec --namespace=vault -it vault-0 -- sh -c "cat $accountPath/token")

    echo "$kubeCert" > "$dir/kubernetes_ca.crt"

    vault write auth/kubernetes/config \
        kubernetes_host='https://kubernetes.default.svc.cluster.local' \
        kubernetes_ca_cert="@$dir/kubernetes_ca.crt" \
        token_reviewer_jwt="$serviceToken"

    dhall-to-text < vault/policies/get-cert.hcl.dhall \
       | vault policy write get-cert -

    vault write auth/kubernetes/role/get-cert \
       bound_service_account_names=default \
       bound_service_account_namespaces='*' \
       generate_lease=true policies=get-cert ttl=2h
fi

./applyDir.sh ldap

user="jan.users"
getIntermediateCert outside "$user"

openssl pkcs12 -export -in "$dir/$user.crt" -inkey "$dir/$user.key" -out "$dir/$user.p12"

for d in $(ls */volume*.yaml.dhall | xargs -n 1 dirname | uniq); do
    if [[ $dev ]]; then
        minikube ssh "su -c 'mkdir -p /data/$d'"
    fi
done
