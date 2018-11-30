let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ServicePort.dhall

in \(_params : { name : Text }) ->
    { name = _params.name
    , type = None Text
    , ports = None (List Port)
    , externalIPs = None (List Text)
    }
