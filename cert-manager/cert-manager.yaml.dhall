let defaultEnvVarSource = ../dhall-kubernetes/default/io.k8s.api.core.v1.EnvVarSource.dhall
let defaultFieldSelector = ../dhall-kubernetes/default/io.k8s.api.core.v1.ObjectFieldSelector.dhall

let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall

let certManagerContainer =
    defaultContainer
        { name = "cert-manager"
        , image = "quay.io/jetstack/cert-manager-controller:v0.6.1"
        }
    //
    { args = Some
        [ "--cluster-resource-namespace=$(POD_NAMESPACE)"
        , "--leader-election-namespace=$(POD_NAMESPACE)"
        ]
    , env = Some
        [ { name = "POD_NAMESPACE"
          , value = None Text
          , valueFrom = Some (
              defaultEnvVarSource
              //
              { fieldRef = Some (defaultFieldSelector { fieldPath = "metadata.namespace" }) })
          }
        ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "cert-manager"
        , namespace = "cert-manager"
        , containers = [certManagerContainer]
        }
    //
    { serviceAccountName = Some "cert-manager"
    }

in ../api/mkDeployment.dhall config
