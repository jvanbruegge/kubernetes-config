let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall

in { name : Text
, replicas : Natural
, containers : List ./Container.dhall
, initContainers : Optional (List ./Container.dhall)
, volumes : Optional (List Volume)
, serviceAccountName : Optional Text
}
