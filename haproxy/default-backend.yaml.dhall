let defaultContainer = ../api/defaultContainer.dhall
let defaultPort = ../api/defaultPort.dhall
let defaultSimpleDeployment = ../api/defaultSimpleDeployment.dhall

let backendContainer =
    defaultContainer
        { name = "ingress-default-backend"
        , image = "gcr.io/google_containers/defaultbackend:1.0"
        }
    //
    { ports = Some [ defaultPort { containerPort = 8080, name = "http" } ]
    } : ../api/Container.dhall

let config =
    defaultSimpleDeployment
        { name = "ingress-default-backend"
        , namespace = "haproxy"
        , containers = [backendContainer]
        }

in ../api/mkDeployment.dhall config
