#!/bin/sh

dir="generated"

mkdir -p "$dir"

if [ ! -e "$dir/rootCA.key" ]; then
    echo "Generating root CA key"
    openssl genrsa -out "$dir/rootCA.key" 2048

    echo "Generating root CA certificate"
    openssl req -x509 -new -nodes -key "$dir/rootCA.key" -config req.conf \
        -days 1068 -out "$dir/rootCA.pem"

    echo "Copying root CA certificate to certificate store"

    uname="$(uname -a)"
    system=""

    case "$uname" in
        *Ubuntu*) system="Ubuntu" ;;
        *ARCH*) system="ARCH" ;;
    esac

    if [ "$system" == "Ubuntu" ]; then

        sudo cp "$dir/rootCA.pem" /usr/local/share/ca-certificates/cerberus-systems.crt
        sudo update-ca-certificates

    elif [ "$system" == "ARCH" ]; then

        cp "$dir/rootCA.pem" "cerberus-systems.crt"
        sudo trust anchor --store cerberus-systems.crt
        rm cerberus-systems.crt

    else
        echo "Your distribution is not configured, please install the root CA certificate yourself"
    fi
fi

function createCert {
    user=$1

    if [ ! -e "$dir/$user.key" ]; then
        echo "Generating client certificate for $user"
        openssl genrsa -out "$dir/$user.key" 4096
        openssl req -new -key "$dir/$user.key" -out "$dir/$user.csr" -config "$user.conf"
        openssl x509 -req -in "$dir/$user.csr" -CA "$dir/rootCA.pem" \
            -CAkey "$dir/rootCA.key" -CAcreateserial -out "$dir/$user.crt" -days 500

        if [[ $2 == "export" ]]; then
            openssl pkcs12 -export -in "$dir/$user.crt" -inkey "$dir/$user.key" \
                -out "$dir/$user.p12"
        fi
    fi
}

createCert vault

echo "Copying vault certificate and key to server"
if [ -x "$(command -v minikube 2>/dev/null)" ]; then
    minikube ssh 'su -c "mkdir -p /data/vault/ssl"'
    ssh -i $(minikube ssh-key) docker@$(minikube ip) \
        'su -c "cat > /data/vault/ssl/vault.key"' < "$dir/vault.key"

    ssh -i $(minikube ssh-key) docker@$(minikube ip) \
        'su -c "cat > /data/vault/ssl/vault.crt"' < "$dir/vault.crt"

    ssh -i $(minikube ssh-key) docker@$(minikube ip) \
        'su -c "cat > /data/vault/ssl/ca.crt"' < "$dir/rootCA.pem"
else
    echo "Please copy the certificates manually to the server"
fi

createCert jan export
