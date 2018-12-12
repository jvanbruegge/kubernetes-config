let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let withLine = ''{{ with secret "pki_int_outside/issue/get-cert" "common_name=ldap.cerberus-systems.de" "alt_names=ldap.cerberus-systems.de,ldap.cerberus-systems.com,ldap.default.svc.cluster.local" "ttl=720h" "format=pem" }}''

let cert = withLine ++ "\n{{ .Data.certificate }}{{ end }}"
let ca = withLine ++ "\n{{ .Data.issuing_ca }}{{ end }}"
let key = withLine ++ "\n{{ .Data.private_key }}{{ end }}"

let config = ''
template {
    source = "/etc/consul-template/cert.tpl"
    destination = "/var/ldap-certs/ldap.crt"
}

template {
    source = "/etc/consul-template/ca.tpl"
    destination = "/var/ldap-certs/ca.crt"
}

template {
    source = "/etc/consul-template/key.tpl"
    destination = "/var/ldap-certs/ldap.key"
}

vault {
    address = "https://vault.default.svc.cluster.local:8300"
    grace = "1h"
    renew_token = true

    ssl {
        enabled = true
        verify = true

        ca_cert = "/var/certs/ca.crt"
    }
}
''

let run = ''
#!/bin/sh

export VAULT_TOKEN=$(cat /home/consul-template/.vault-token)
docker-entrypoint.sh -once -config "/etc/consul-template/config.hcl"
''

in
    defaultConfigMap { metadata = defaultMetadata { name = "ldap-consul-template-config" } }
    //
    { data = Some
        [ { mapKey = "cert.tpl", mapValue = cert }
        , { mapKey = "ca.tpl", mapValue = ca }
        , { mapKey = "key.tpl", mapValue = key }
        , { mapKey = "config.hcl", mapValue = config }
        , { mapKey = "run.sh", mapValue = run }
        ]
    }

