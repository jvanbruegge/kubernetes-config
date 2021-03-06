let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ContainerPort.dhall

in \(_params : { containerPort : Natural, name : Text }) ->
    { containerPort = _params.containerPort
    , name = Some _params.name
    , protocol = Some "TCP"
    , hostPort = None Natural
    , hostIP = None Text
    } : Port

