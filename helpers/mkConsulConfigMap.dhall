let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let prelude = https://prelude.dhall-lang.org/package.dhall
  sha256:534e4a9e687ba74bfac71b30fc27aa269c0465087ef79bf483e876781602a454

let hosts = ../hostnames.dhall

let cnBase = prelude.`Optional`.fold
    Text
    (prelude.`List`.head Text hosts)
    Text
    (\(x : Text) -> x)
    "example.com"

let foldSans = \(subdomain : Text) -> \(hosts : List Text) ->
    prelude.`Text`.concatSep ","
        (prelude.`List`.map Text Text (\(x : Text) -> subdomain ++ "." ++ x) hosts)

let withLine = \(subdomain : Text) -> \(namespace : Text) ->
    ''{{ with secret "pki_int_outside/issue/get-cert" "common_name=''
    ++ "${subdomain}.${cnBase}\" \"alt_names="
    ++ foldSans subdomain (hosts # [namespace ++ ".svc.cluster.local"])
    ++ ''" "ttl=720h" "format=pem" }}''

let certTemplate = \(subdomain : Text) -> \(namespace : Text) -> \(entry : Text) ->
    let line = withLine subdomain namespace
    in "${line}\n{{ .Data.${entry} }}\n{{ end }}"

let baseConfig = ''
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

let templateConfig = \(filenames : List Text) ->
    let templates = prelude.`List`.map Text Text
        (\(x : Text) -> ''template {
            source = "/etc/consul-template/'' ++ x ++ ''.tpl"
            destination = "/var/generated/'' ++ x ++ ''"
        }'')
        filenames
    in prelude.`Text`.concatSep "\n" (templates # [baseConfig])

let run = ''
#!/bin/sh

export VAULT_TOKEN=$(cat /home/consul-template/.vault-token)
docker-entrypoint.sh -once -config "/etc/consul-template/config.hcl"
''

let CertOptions =
    { certFilename : Text
    , keyFilename : Text
    , caFilename : Text
    , namespace : Text
    , subdomain : Text
    }

let mkConfigMap = \(_params : CertOptions) ->
    let filenames = [_params.certFilename, _params.keyFilename, _params.caFilename]
    let mkTemplate = certTemplate _params.subdomain _params.namespace

    in defaultConfigMap { metadata =
        defaultMetadata { name = "consul-template-config" }
        //
        { namespace = Some _params.namespace }
    }
    //
    { data = Some
        [ { mapKey = _params.certFilename ++ ".tpl", mapValue = mkTemplate "certificate" }
        , { mapKey = _params.keyFilename ++ ".tpl", mapValue = mkTemplate "private_key" }
        , { mapKey = _params.caFilename ++ ".tpl", mapValue = mkTemplate "issuing_ca" }
        , { mapKey = "config.hcl", mapValue = templateConfig filenames }
        , { mapKey = "run.sh", mapValue = run }
        ]
    }

in mkConfigMap
