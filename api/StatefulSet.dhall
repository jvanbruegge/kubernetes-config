{ name : Text
, containers : List ./Container.dhall
, initContainers : Optional (List ./Container.dhall)
, replicas : Natural
, volumes : Optional (List ./Volume.dhall)
}
