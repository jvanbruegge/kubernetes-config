#!/bin/bash

dir="generated"
export VAULT_ADDR="https://vault.cerberus-systems.de"
export VAULT_CACERT="$dir/pki_int_outside.crt"
export VAULT_CLIENT_CERT="$dir/vault-operator.crt"
export VAULT_CLIENT_KEY="$dir/vault-operator.key"

vaultKeys=$(cat vault_keys.txt)

for i in 1 2 3; do
    key=$(echo "$vaultKeys" | grep "Unseal Key $i:" | awk '{print $NF}')

    vault operator unseal "$key" > /dev/null
done
echo "Vault unsealed"
