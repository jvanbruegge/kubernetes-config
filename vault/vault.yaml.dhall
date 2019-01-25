let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall
let utils = ../api/utils.dhall

let config = ./config.dhall
let volumeName = "store"

let vaultContainer =
    defaultContainer
        { name = "vault"
        , image = "registry.hub.docker.com/cerberussystems/vault-secret-gen:1.0.0"
        }
    //
    { command = Some ["sh"]
    , args = Some ["/scripts/runVault.sh"]
    , env = Some
        [{ name = "VAULT_LOCAL_CONFIG"
        , value = Some ./vault.tcl.dhall
        , valueFrom = None EnvVarSource
        }]
    , securityContext = Some (utils.addCapabilities ["IPC_LOCK"])
    , ports = Some [defaultPort { containerPort = config.port, name = "vault-port" }]
    , volumeMounts = Some
        [defaultVolumeMount
            { mountPath = config.path
            , name = volumeName
            }
        , defaultVolumeMount
            { mountPath = "/scripts"
            , name = "vault-configmap"
            }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "vault"
        , namespace = "vault"
        , containers = [vaultContainer]
        }
    //
    { volumes = Some
        [ ../api/mkVolume.dhall
            { name = volumeName, volumeType = <PVC = "vault-claim" | ConfigMap : Text> }
        , ../api/mkVolume.dhall
            { name = "vault-configmap"
            , volumeType = <ConfigMap = "vault-config" | PVC : Text>
            }
        ]
    , serviceAccountName = Some "vault-auth"
    }

in ../api/mkStatefulSet.dhall config
