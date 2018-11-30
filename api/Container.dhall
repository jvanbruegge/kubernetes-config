let EnvVar = ../dhall-kubernetes/types/io.k8s.api.core.v1.EnvVar.dhall
let SecurityContext = ../dhall-kubernetes/types/io.k8s.api.core.v1.SecurityContext.dhall
let Port = ../dhall-kubernetes/types/io.k8s.api.core.v1.ContainerPort.dhall
let VolumeMount = ../dhall-kubernetes/types/io.k8s.api.core.v1.VolumeMount.dhall
let Probe = ../dhall-kubernetes/types/io.k8s.api.core.v1.Probe.dhall

in { name : Text
, image : Text
, env : Optional (List EnvVar)
, command : Optional (List Text)
, args : Optional (List Text)
, securityContext : Optional SecurityContext
, ports : Optional (List Port)
, volumeMounts: Optional (List VolumeMount)
, readinessProbe : Optional Probe
}
