let Container = ../dhall-kubernetes/types/io.k8s.api.core.v1.Container.dhall
let defaultContainer = ../dhall-kubernetes/default/io.k8s.api.core.v1.Container.dhall

let utils = ./utils.dhall

in \(c : ./Container.dhall) ->
    defaultContainer { name = c.name }
    //
    { image = Some c.image
    , imagePullPolicy = Some "IfNotPresent"
    , ports = c.ports
    , readinessProbe = c.readinessProbe
    , livenessProbe = c.livenessProbe
    , args = c.args
    , command = c.command
    , securityContext = c.securityContext
    , volumeMounts = c.volumeMounts
    , env = c.env
    } : Container
