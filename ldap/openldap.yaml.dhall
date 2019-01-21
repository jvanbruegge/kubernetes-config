let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultVolumeMount = ../api/defaultVolumeMount.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall

let volumeName = "store"

let withCerts = ../helpers/withCerts.dhall

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
        , { name = "LDAP_TLS_ENFORCE"
          , value = Some "true"
          , valueFrom = None EnvVarSource }
        ]
    , ports = Some [defaultPort { containerPort = 636, name = "ldaps" }]
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
        , defaultVolumeMount
            { mountPath = "/container/service/slapd/assets/certs"
            , name = "ldap-certs"
            }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "openldap"
        , namespace = "ldap"
        , containers = [ldapContainer]
        }
    //
    { volumes = Some
        [ ../api/mkVolume.dhall
            { name = volumeName, volumeType = <PVC = "data-claim" | ConfigMap : Text> }
        ]
    }

in ../api/mkStatefulSet.dhall (withCerts "ldap-certs" config)
