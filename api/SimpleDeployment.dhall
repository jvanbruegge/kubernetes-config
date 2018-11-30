{ name : Text
, replicas : Natural
, containers : List ./Container.dhall
, initContainers : Optional (List ./Container.dhall)
, volumes : Optional (List ./Volume.dhall)
, serviceAccountName : Optional Text
}
