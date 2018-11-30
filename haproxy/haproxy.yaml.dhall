let defaultEnvVarSource = ../dhall-kubernetes/default/io.k8s.api.core.v1.EnvVarSource.dhall
let defaultFieldSelector = ../dhall-kubernetes/default/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall

let haProxyContainer =
    defaultContainer
        { name = "haproxy-ingress"
        , image = "quay.io/jcmoraisjr/haproxy-ingress:v0.6"
        }
    //
    { args = Some
        [ "--default-backend-service=default/ingress-default-backend"
        , "--configmap=default/haproxy-config"
        , "--reload-strategy=native"
        ]
    , env = Some
        [ { name = "POD_NAME"
          , value = None Text
          , valueFrom = Some (
              defaultEnvVarSource
              //
              { fieldRef = Some (defaultFieldSelector { fieldPath = "metadata.name" }) })
          }
        , { name = "POD_NAMESPACE"
          , value = None Text
          , valueFrom = Some (
              defaultEnvVarSource
              //
              { fieldRef = Some (defaultFieldSelector { fieldPath = "metadata.namespace" }) })
          }
        ]
    , ports = Some
        [ defaultPort { containerPort = 80, name = "http" }
        , defaultPort { containerPort = 443, name = "https" }
        , defaultPort { containerPort = 1936, name = "stats" }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "haproxy"
        , containers = [haProxyContainer]
        }
    //
    { serviceAccountName = Some "ingress-controller"
    }

in ../api/mkDeployment.dhall config
