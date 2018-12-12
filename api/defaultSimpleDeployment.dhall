let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall

in \(_params : { name : Text, containers : List ./Container.dhall }) ->
    _params
    //
    { replicas = 1
    , initContainers = None (List ./Container.dhall)
    , volumes = None (List Volume)
    , serviceAccountName = None Text
    } : ./SimpleDeployment.dhall
