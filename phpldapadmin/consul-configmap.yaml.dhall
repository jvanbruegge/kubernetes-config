let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let withLine = ''{{ with secret "pki_int_outside/issue/get-cert" "common_name=phpldapadmin.cerberus-systems.de" "alt_names=phpldapadmin.cerberus-systems.de,phpldapadmin.cerberus-systems.com,phpldapadmin.default.svc.cluster.local" "ttl=720h" "format=pem" }}''

let cert = withLine ++ "\n{{ .Data.certificate }}{{ end }}"
let ca = withLine ++ "\n{{ .Data.issuing_ca }}{{ end }}"
let key = withLine ++ "\n{{ .Data.private_key }}{{ end }}"

let dir = "/var/https-certs"
let ldap = "/var/ldap-certs"

let config = ''
template {
    source = "/etc/consul-template/cert.tpl"
    destination = "'' ++ dir ++ ''/phpldapadmin.crt"
}

template {
    source = "/etc/consul-template/ca.tpl"
    destination = "'' ++ dir ++ ''/ca.crt"
}

template {
    source = "/etc/consul-template/key.tpl"
    destination = "'' ++ dir ++ ''/phpldapadmin.key"
}

template {
    source = "/etc/consul-template/cert.tpl"
    destination = "'' ++ ldap ++ ''/ldap-client.crt"
}

template {
    source = "/etc/consul-template/key.tpl"
    destination = "'' ++ ldap ++ ''/ldap-client.key"
}

vault {
    address = "https://vault.default.svc.cluster.local:8300"
    grace = "1h"
    renew_token = true

    ssl {
        enabled = true
        verify = true

        ca_cert = "/var/certs/pki_int_outside.crt"
    }
}
''

let run = ''
#!/bin/sh

cp -v /certs/ca.crt '' ++ ldap ++ ''/ldap-ca.crt
export VAULT_TOKEN=$(cat /home/consul-template/.vault-token)
docker-entrypoint.sh -once -config "/etc/consul-template/config.hcl"
''

in
    defaultConfigMap { metadata = defaultMetadata { name = "phpldapadmin-consul-template-config" } }
    //
    { data = Some
        [ { mapKey = "cert.tpl", mapValue = cert }
        , { mapKey = "ca.tpl", mapValue = ca }
        , { mapKey = "key.tpl", mapValue = key }
        , { mapKey = "config.hcl", mapValue = config }
        , { mapKey = "run.sh", mapValue = run }
        ]
    }

