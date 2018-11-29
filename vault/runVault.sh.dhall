let config = ./vaultConfig.dhall

in ''
#!/bin/bash

mkdir -p /vault/config
chown -R vault:vault /vault

docker-entrypoint.sh server
''
