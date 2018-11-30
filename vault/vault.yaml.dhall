let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let utils = ../api/utils.dhall

let config = ./config.dhall
let volumeName = "store"

let vaultContainer =
    defaultContainer
        { name = "vault"
        , image = "registry.hub.docker.com/library/vault:0.11.5"
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
          // { subPath = Some "vault" }
        , defaultVolumeMount
            { mountPath = "/scripts"
            , name = "vault-configmap"
            }
        ]
    {-, readinessProbe = Some (utils.httpGetProbe
        { path = "/v1/sys/health?standbyok=true"
        , port = config.port
        , scheme = "HTTP"
        })-}
    } : ../api/Container.dhall

let config =
    { name = "vault"
    , containers = [vaultContainer]
    , initContainers = None (List ../api/Container.dhall)
    , replicas = 1
    , volumes = Some
        [ { name = volumeName, volumeType = <PVC = "data-claim" | ConfigMap : Text> }
        , { name = "vault-configmap", volumeType = <ConfigMap = "vault-config" | PVC : Text> }
        ]
    }

in ../api/mkStatefulSet.dhall config
