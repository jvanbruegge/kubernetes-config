let EnvVarSource = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVarSource.dhall

let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.Volume.dhall
let defaultDirVolumeSource = ../dhall-kubernetes/default/io.k8s.api.core.v1.EmptyDirVolumeSource.dhall
let defaultSecret = ../dhall-kubernetes/default/io.k8s.api.core.v1.SecretVolumeSource.dhall
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
        , { name = "LDAP_TLS_ENFORCE"
          , value = Some "true"
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
        , defaultVolumeMount
            { mountPath = "/container/service/slapd/assets/certs"
            , name = "ldap-certs"
            }
        ]
    } : ../api/Container.dhall

let consulTemplateContainer =
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
            , name = "root-ca"
            }
        , defaultVolumeMount
            { mountPath = "/var/ldap-certs"
            , name = "ldap-certs"
            }
        ]
    }
    : ../api/Container.dhall

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
          , value = Some "https://vault.default.svc.cluster.local:8300"
          , valueFrom = None EnvVarSource }
        , { name = "VAULT_CACERT"
          , value = Some "/var/certs/ca.crt"
          , valueFrom = None EnvVarSource }
        ]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/home/vault"
            , name = "vault-token"
            }
        , defaultVolumeMount
            { mountPath = "/var/certs"
            , name = "root-ca"
            }
        ]
    }

let config =
    defaultSimpleDeployment
        { name = "openldap"
        , containers = [ldapContainer]
        }
    //
    { volumes = Some
        [ ../api/mkVolume.dhall
            { name = volumeName, volumeType = <PVC = "data-claim" | ConfigMap : Text> }
        , ../api/mkVolume.dhall
            { name = "consul-config"
            , volumeType = <PVC : Text | ConfigMap = "ldap-consul-template-config">
            }
        , defaultVolume { name = "vault-token" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "ldap-certs" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "root-ca" }
            //
            { secret = Some (defaultSecret // { secretName = Some "root-ca" }) }
        ]
    , initContainers = Some [vaultAuthenticator, consulTemplateContainer]
    }

in ../api/mkStatefulSet.dhall config
