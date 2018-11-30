let config = ./config.dhall

in ''
#!/bin/bash

vaultDir='' ++ config.path ++ ''

mkdir -p "$vaultDir/config"
chown -R vault:vault "$vaultDir"

docker-entrypoint.sh server
''
