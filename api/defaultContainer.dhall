let EnvVar = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVar.dhall
let SecurityContext = ../dhall-kubernetes/types/io.k8s.api.core.v1.SecurityContext.dhall
let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ContainerPort.dhall
let VolumeMount = ../dhall-kubernetes/types/io.k8s.api.core.v1.VolumeMount.dhall
let Probe = ../dhall-kubernetes/types/io.k8s.api.core.v1.Probe.dhall

in \(_params : { name : Text, image : Text }) ->
    _params
    //
    { env = None (List EnvVar)
    , args = None (List Text)
    , command = None (List Text)
    , securityContext = None SecurityContext
    , ports = None (List Port)
    , volumeMounts = None (List VolumeMount)
    , readinessProbe = None Probe
    , livenessProbe = None Probe
    } : ./Container.dhall
