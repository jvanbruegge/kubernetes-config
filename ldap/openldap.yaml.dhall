let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall
let utils = ../api/utils.dhall

let volumeName = "store"

let ldapContainer =
    defaultContainer
        { name = "openldap"
        , image = "registry.hub.docker.com/osixia/openldap:1.2.2"
        }
    //
    { env = Some
        [ { name = "LDAP_ORGANISATION"
          , value = Some "Cerberus Systems"
          , valueFrom = None EnvVarSource }
        , { name = "LDAP_DOMAIN"
          , value = Some "cerberus-systems.de"
          , valueFrom = None EnvVarSource }
        , { name = "LDAP_ADMIN_PASSWORD"
          , value = Some "admin"
          , valueFrom = None EnvVarSource }
        ]
    , ports = Some [defaultPort { containerPort = 389, name = "openldap" }]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/var/lib/ldap"
            , name = volumeName
            }
          // { subPath = Some "ldap/data" }
        , defaultVolumeMount
            { mountPath = "/etc/ldap/slapd.d"
            , name = volumeName
            }
          // { subPath = Some "ldap/config" }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "openldap"
        , containers = [ldapContainer]
        }
    //
    { volumes = Some
        [ { name = volumeName, volumeType = <PVC = "data-claim" | ConfigMap : Text> } ]
    }

in ../api/mkStatefulSet.dhall config
