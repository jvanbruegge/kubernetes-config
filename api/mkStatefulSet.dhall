let StatefulSet = ../dhall-kubernetes/types/io.k8s.api.apps.v1.StatefulSet.dhall

let defaultSet = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSet.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSetSpec.dhall

in \(set: ./SimpleDeployment.dhall) ->
    let metadata = ./defaultMetadata.dhall { name = set.name }

    in
        defaultSet { metadata = metadata }
        //
        { spec = Some (
            defaultSpec
                { serviceName = set.name
                , selector = ./mkSelector.dhall set
                , template = ./mkTemplate.dhall metadata set
                }
            //
            { replicas = Some set.replicas })
        } : StatefulSet
