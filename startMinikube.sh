#!/bin/sh

# This script is needed because the IP address of the VM cannot be made static
minikube start

ip=$(minikube ip)

sudo sed -i -e "s/cerberus-systems\.de\/192\.168\.99\..../cerberus-systems.de\/${ip}/" /etc/dnsmasq.conf

sudo systemctl restart dnsmasq

echo "\"$ip\"" > minikube-ip.dhall

if [[ -z "$1" ]]; then
    ./applyDir.sh haproxy
    ./unseal_vault_dev.sh
fi
