let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.Volume.dhall
let defaultContainer = ../api/defaultContainer.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let defaultDirVolumeSource = ../dhall-kubernetes/default/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall
let defaultSecret = ../dhall-kubernetes/default/io.k8s.api.core.v1.SecretVolumeSource.dhall

let Container = ../api/Container.dhall
let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall
let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let prelude = https://prelude.dhall-lang.org/package.dhall
  sha256:534e4a9e687ba74bfac71b30fc27aa269c0465087ef79bf483e876781602a454

let vaultAuthenticator =
    defaultContainer
        { name = "vault-kubernetes-authenticator"
        , image = "registry.hub.docker.com/sethvargo/vault-kubernetes-authenticator:0.1.2"
        }
    //
    { env = Some
        [ { name = "TOKEN_DEST_PATH"
          , value = Some "/home/vault/.vault-token"
          , valueFrom = None EnvVarSource }
        , { name = "VAULT_ROLE"
          , value = Some "get-cert"
          , valueFrom = None EnvVarSource }
        , { name = "VAULT_ADDR"
          , value = Some "https://vault.vault.svc.cluster.local:8300"
          , valueFrom = None EnvVarSource }
        , { name = "VAULT_CACERT"
          , value = Some "/var/certs/pki_int_outside.crt"
          , valueFrom = None EnvVarSource }
        ]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/home/vault"
            , name = "vault-token"
            }
        , defaultVolumeMount
            { mountPath = "/var/certs"
            , name = "consul-template-ca-outside"
            }
        ]
    }
    : Container

let consulTemplateContainer = \(certMount : Text) ->
    defaultContainer
        { name = "consul-template"
        , image = "registry.hub.docker.com/hashicorp/consul-template:0.19.5-alpine"
        }
    //
    { command = Some ["sh"]
    , args = Some ["/etc/consul-template/run.sh"]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/etc/consul-template"
            , name = "consul-config"
            }
        , defaultVolumeMount
            { mountPath = "/home/consul-template"
            , name = "vault-token"
            }
        , defaultVolumeMount
            { mountPath = "/var/certs"
            , name = "consul-template-ca-outside"
            }
        , defaultVolumeMount
            { mountPath = "/var/root-ca"
            , name = "consul-template-root-ca"
            }
        , defaultVolumeMount
            { mountPath = "/var/generated"
            , name = certMount
            }
        ]
    }
    : Container

let appendOptional = \(a : Type) -> \(xs : Optional (List a)) -> \(new : List a) ->
    Some (prelude.`List`.concat a (prelude.`Optional`.toList (List a) xs) # new)

let withCerts = \(certVolumeName : Text) -> \(deployment : ../api/SimpleDeployment.dhall) ->
    let volumes =
        [ defaultVolume { name = certVolumeName }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "consul-template-root-ca" }
            //
            { secret = Some (defaultSecret // { secretName = Some "root-ca" }) }
        , defaultVolume { name = "consul-template-ca-outside" }
            //
            { secret = Some (defaultSecret // { secretName = Some "ca-outside" }) }
        , defaultVolume { name = "vault-token" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , ../api/mkVolume.dhall
            { name = "consul-config"
            , volumeType = <PVC : Text | ConfigMap = "consul-template-config">
            }
        ]

    let initContainers = [vaultAuthenticator, consulTemplateContainer certVolumeName]

    in deployment
        //
        { volumes = appendOptional Volume deployment.volumes volumes
        , initContainers = appendOptional Container deployment.initContainers initContainers
        }

in withCerts
