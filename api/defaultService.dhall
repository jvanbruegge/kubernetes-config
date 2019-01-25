let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ServicePort.dhall

in \(_params : { name : Text, namespace : Text }) ->
    { name = _params.name
    , namespace = _params.namespace
    , type = None Text
    , ports = None (List Port)
    , externalIPs = None (List Text)
    }
