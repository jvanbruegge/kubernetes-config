let StatefulSet = ../dhall-kubernetes/types/io.k8s.api.apps.v1.StatefulSet.dhall

let defaultSet = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSet.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSetSpec.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in \(set: ./SimpleDeployment.dhall) ->
    let m = { name = set.name }
    in
        defaultSet { metadata =
            defaultMetadata m
            //
            { namespace = Some set.namespace }
        }
        //
        { spec = Some (
            defaultSpec
                { serviceName = set.name
                , selector = ./mkSelector.dhall set
                , template = ./mkTemplate.dhall (./defaultMetadata.dhall m) set
                }
            //
            { replicas = Some set.replicas })
        } : StatefulSet
