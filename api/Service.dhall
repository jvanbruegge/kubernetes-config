let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ServicePort.dhall

in
    { name : Text
    , namespace : Text
    , type : Optional Text
    , ports : Optional (List Port)
    , externalIPs : Optional (List Text)
    }
