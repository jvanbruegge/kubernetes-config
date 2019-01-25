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
    address = "https://vault.vault.svc.cluster.local:8300"
    grace = "1h"
    renew_token = true

    ssl {
        enabled = true
        verify = true

        ca_cert = "/var/certs/pki_int_outside.crt"
    }
}
''

let Location = { subdir : Optional Text, name : Text }

let concatWith = \(sep : Text) -> \(l : Location) ->
    Optional/fold Text
        (prelude.`Optional`.map Text Text (\(x : Text) -> x ++ sep ++ l.name) l.subdir)
        Text
        (\(x : Text) -> x)
        l.name

let templateConfig = \(filenames : List Location) ->
    let templates = prelude.`List`.map Location Text
        (\(x : Location) -> ''template {
            source = "/etc/consul-template/'' ++ concatWith "_" x ++ ''.tpl"
            destination = "/var/generated/'' ++ concatWith "/" x ++ ''"
        }'')
        filenames
    in prelude.`Text`.concatSep "\n" (templates # [baseConfig])

let run = ''
#!/bin/sh

export VAULT_TOKEN=$(cat /home/consul-template/.vault-token)
docker-entrypoint.sh -once -config "/etc/consul-template/config.hcl"

while read s; do
    cp -v /var/root-ca/ca.crt "/var/generated/$s"
done < /etc/consul-template/rootCaLocations.txt
''

let expand = \(subdomain : Text) -> \(namespace : Text) -> \(data : Text) ->
    let mkTemplate = certTemplate subdomain namespace
    in prelude.`List`.map Location { mapKey : Text, mapValue : Text }
        (\(x : Location) -> { mapKey = concatWith "_" x ++ ".tpl", mapValue = mkTemplate data })

let mkRootCaLocations = \(l : List Location) ->
    prelude.`Text`.concatSep "\n"
        (prelude.`List`.map Location Text (concatWith "/") l)
    ++ "\n"

let CertOptions =
    { certFilenames : List Location
    , keyFilenames : List Location
    , caFilenames : List Location
    , rootCaFilenames : List Location
    , namespace : Text
    , subdomain : Text
    }

let mkConfigMap = \(_params : CertOptions) ->
    let filenames = _params.certFilenames # _params.keyFilenames # _params.caFilenames
    let exp = expand _params.subdomain _params.namespace

    in defaultConfigMap { metadata =
        defaultMetadata { name = "consul-template-config" }
        //
        { namespace = Some _params.namespace }
    }
    //
    { data = Some (
        exp "certificate" _params.certFilenames
        #
        exp "private_key" _params.keyFilenames
        #
        exp "issuing_ca" _params.caFilenames
        #
        [ { mapKey = "config.hcl", mapValue = templateConfig filenames }
        , { mapKey = "rootCaLocations.txt", mapValue = mkRootCaLocations _params.rootCaFilenames }
        , { mapKey = "run.sh", mapValue = run }
        ])
    }

in mkConfigMap
