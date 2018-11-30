let defaultPort = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServicePort.dhall

in \(port : Natural) ->
    defaultPort { port = port }
    //
    { targetPort = Some <Int = port | String : Text>
    , protocol = Some "TCP"
    }

