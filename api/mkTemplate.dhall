let Template = ../dhall-kubernetes/types/io.k8s.api.core.v1.PodTemplateSpec.dhall
let Container = ../dhall-kubernetes/types/io.k8s.api.core.v1.Container.dhall
let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall
let Metadata = ../dhall-kubernetes/types/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let listMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map
let maybeMap = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Optional/map

let defaultPodSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.PodSpec.dhall

in \(metadata : Metadata) -> \(_param : ./SimpleDeployment.dhall) ->
    { metadata = metadata
    , spec = Some (
        defaultPodSpec
            { containers = listMap
                ./Container.dhall Container ./mkContainer.dhall _param.containers
            }
        //
        { volumes = _param.volumes
        , initContainers = maybeMap (List ./Container.dhall) (List Container)
              (listMap ./Container.dhall Container ./mkContainer.dhall) _param.initContainers
        , serviceAccountName = _param.serviceAccountName
        })
    } : Template
