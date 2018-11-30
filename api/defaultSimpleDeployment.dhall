\(_params : { name : Text, containers : List ./Container.dhall }) ->
    _params
    //
    { replicas = 1
    , initContainers = None (List ./Container.dhall)
    , volumes = None (List ./Volume.dhall)
    , serviceAccountName = None Text
    } : ./SimpleDeployment.dhall
