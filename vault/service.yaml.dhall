let defaultService = ../dhall-kubernetes/default/io.k8s.api.core.v1.Service.dhall
let defaultPort = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServicePort.dhall
let config = ./vaultConfig.dhall

in ../api/mkService
    { name = "vault"
    , type = Some "NodePort"
    , ports = Some [
        defaultPort { port = config.port }
        //
        { targetPort = Some <Int = config.port | String : Text>
        , protocol = Some "TCP"
        }]
    }
