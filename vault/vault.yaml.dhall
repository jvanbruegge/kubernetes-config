let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultContainer = ../api/defaultContainer
let defaultPort = ../api/defaultPort
let defaultVolumeMount = ../api/defaultVolumeMount
let utils = ../api/utils.dhall

let config = ./vaultConfig.dhall

let vaultContainer =
    defaultContainer
        { name = "vault"
        , image = "registry.hub.docker.com/library/vault:0.11.5"
        }
    //
    { args = Some ["server"]
    , env = Some
        [{ name = "VAULT_LOCAL_CONFIG"
        , value = Some config.file
        , valueFrom = None EnvVarSource
        }]
    , securityContext = Some (utils.addCapabilities ["IPC_LOCK"])
    , ports = Some [defaultPort { containerPort = config.port, name = "vault-port" }]
    , volumeMounts = Some
        [defaultVolumeMount
            { mountPath = config.path
            , name = "store"
            }
          // { subPath = Some "vault" }
        , defaultVolumeMount
            { mountPath = config.sslPath
            , name = "store"
            }
          // { subPath = Some "rootCA" }
        ]
    {-, readinessProbe = Some (utils.httpGetProbe
        { path = "/v1/sys/health?standbyok=true"
        , port = config.port
        , scheme = "HTTP"
        })-}
    } : ../api/Container

let sslInit =
    defaultContainer
        { name = "init-root-ca"
        , image = "registry.hub.docker.com/governmentpaas/curl-ssl:6efea7a479f9336019155cc039ad33d2c8845cb0"
        }
    //
    { command = Some ["sh"]
    , args = Some ["/run/run.sh"]
    , volumeMounts = Some
        [defaultVolumeMount
            { mountPath = config.sslPath
            , name = "store"
            }
          // { subPath = Some "rootCA" }
        , defaultVolumeMount
            { mountPath = "/run"
            , name = "ssl-configmap"
            }
        ]
    }

let config =
    { name = "vault"
    , containers = [vaultContainer]
    , initContainers = Some [sslInit]
    , replicas = 1
    , volumes = Some
        [ { name = "store", volumeType = <PVC = "data-claim" | ConfigMap : Text> }
        , { name = "ssl-configmap", volumeType = <ConfigMap = "ssl-config" | PVC : Text> }
        ]
    }

in ../api/mkStatefulSet config
