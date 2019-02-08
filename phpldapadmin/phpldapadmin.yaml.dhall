let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.Volume.dhall
let defaultDirVolumeSource = ../dhall-kubernetes/default/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall
let defaultSecret = ../dhall-kubernetes/default/io.k8s.api.core.v1.SecretVolumeSource.dhall
let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall
let utils = ../api/utils.dhall

let adminContainer =
    defaultContainer
        { name = "phpldapadmin"
        , image = "registry.hub.docker.com/osixia/phpldapadmin:0.7.2"
        }
    //
    { env = Some
        [ { name = "PHPLDAPADMIN_SERVER_PATH"
          , value = Some "/"
          , valueFrom = None EnvVarSource }
        , { name = "PHPLDAPADMIN_HTTPS"
          , value = Some "true"
          , valueFrom = None EnvVarSource }
       ]
    , ports = Some [defaultPort { containerPort = 443, name = "https" }]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/container/service/ldap-client/assets/certs"
            , name = "ldap-certs"
            }
          // { subPath = Some "ldap" }
        , defaultVolumeMount
            { mountPath = "/container/service/phpldapadmin/assets/apache2/certs"
            , name = "ldap-certs"
            }
          // { subPath = Some "https" }
        , defaultVolumeMount
            { mountPath = "/container/environment/01-custom"
            , name = "config"
            }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "phpldapadmin"
        , namespace = "phpldapadmin"
        , containers = [adminContainer]
        }
    //
    { volumes = Some
        [ ../api/mkVolume.dhall
            { name = "config", volumeType = <PVC : Text | ConfigMap = "config"> }
        ]
    }

in ../api/mkDeployment.dhall (../helpers/withCerts.dhall "ldap-certs" config)
