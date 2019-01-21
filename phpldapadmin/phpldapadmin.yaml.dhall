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

let adminContainer =
    defaultContainer
        { name = "phpldapadmin"
        , image = "registry.hub.docker.com/osixia/phpldapadmin:0.7.2"
        }
    //
    { env = Some
        [ { name = "PHPLDAPADMIN_LDAP_HOSTS"
          , value = Some "#PYTHON2BASH:[{'ldaps://ldap.cerberus-systems.de/': [{'server': [{'tls': True, 'port': 0}]}]}]"
          , valueFrom = None EnvVarSource }
        , { name = "PHPLDAPADMIN_SERVER_PATH"
          , value = Some "/"
          , valueFrom = None EnvVarSource }
        , { name = "PHPLDAPADMIN_HTTPS"
          , value = Some "true"
          , valueFrom = None EnvVarSource }
        ]
    , ports = Some [defaultPort { containerPort = 443, name = "https" }]
    , volumeMounts = Some
        [ defaultVolumeMount
            { mountPath = "/container/service/ldap-client/assets/certs/"
            , name = "ldap-certs"
            }
        , defaultVolumeMount
            { mountPath = "/container/service/phpldapadmin/assets/apache2/certs/"
            , name = "https-certs"
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
            , name = "phpldapadmin-consul-config"
            }
        , defaultVolumeMount
            { mountPath = "/home/consul-template"
            , name = "vault-token"
            }
        , defaultVolumeMount
            { mountPath = "/var/certs"
            , name = "ca-outside"
            }
        , defaultVolumeMount
            { mountPath = "/certs"
            , name = "root-ca"
            }
        , defaultVolumeMount
            { mountPath = "/var/ldap-certs"
            , name = "ldap-certs"
            }
        , defaultVolumeMount
            { mountPath = "/var/https-certs"
            , name = "https-certs"
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
            , name = "ca-outside"
            }
        ]
    }

let config =
    defaultSimpleDeployment
        { name = "phpldapadmin"
        , containers = [adminContainer]
        }
    //
    { volumes = Some
        [ ../api/mkVolume.dhall
            { name = volumeName, volumeType = <PVC = "data-claim" | ConfigMap : Text> }
        , ../api/mkVolume.dhall
            { name = "phpldapadmin-consul-config"
            , volumeType = <PVC : Text | ConfigMap = "phpldapadmin-consul-template-config">
            }
        , defaultVolume { name = "vault-token" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "ldap-certs" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "https-certs" }
            //
            { emptyDir = Some (defaultDirVolumeSource // { medium = Some "Memory" }) }
        , defaultVolume { name = "ca-outside" }
            //
            { secret = Some (defaultSecret // { secretName = Some "ca-outside" }) }
        , defaultVolume { name = "root-ca" }
            //
            { secret = Some (defaultSecret // { secretName = Some "root-ca" }) }
        ]
    , initContainers = Some [vaultAuthenticator, consulTemplateContainer]
    }

in ../api/mkStatefulSet.dhall config
