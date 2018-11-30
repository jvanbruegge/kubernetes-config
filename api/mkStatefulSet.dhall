let StatefulSet = ../dhall-kubernetes/types/io.k8s.api.apps.v1.StatefulSet.dhall
let Container = ../dhall-kubernetes/types/io.k8s.api.core.v1.Container.dhall
let Template = ../dhall-kubernetes/types/io.k8s.api.core.v1.PodTemplateSpec.dhall
let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall

let listMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map
let maybeMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Optional/map

let defaultSet = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSet.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.apps.v1.StatefulSetSpec.dhall
let defaultPodSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.PodSpec.dhall
let defaultLabels = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

let utils = ./utils.dhall

in \(set: ./StatefulSet.dhall) ->
    let metadata = ./defaultMetadata.dhall { name = set.name }
    let template =
        { metadata = metadata
        , spec = Some (
            defaultPodSpec
                { containers = listMap
                    ./Container.dhall Container ./mkContainer.dhall set.containers
                }
            //
            { volumes = maybeMap (List ./Volume.dhall) (List Volume)
                  (listMap ./Volume.dhall Volume ./mkVolume.dhall) set.volumes
            , initContainers = maybeMap (List ./Container.dhall) (List Container)
                  (listMap ./Container.dhall Container ./mkContainer.dhall) set.initContainers
            })
        } : Template

    in
        defaultSet { metadata = metadata }
        //
        { spec = Some (
            defaultSpec
                { serviceName = set.name
                , selector =
                    defaultLabels
                    //
                    { matchLabels = Some [{ mapKey = "app", mapValue = set.name }] }
                , template = template
                }
            //
            { replicas = Some set.replicas })
        } : StatefulSet
