\(sslDir : Text) ->
''
#!/bin/sh

sslDir="'' ++ sslDir ++ ''"

if [ ! -e "$sslDir/vault.key" ]; then
    openssl req -x509 -newkey rsa:2048 -nodes -keyout "$sslDir/vault.key" -out "$sslDir/vault.crt" -days 365 -subj "/CN=vault.kube-system.svc.cluster.local"
fi''