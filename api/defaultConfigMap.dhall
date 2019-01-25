let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let defaultConfigMap = \(_params : { name : Text, namespace : Text }) ->
    defaultConfigMap { metadata =
        defaultMetadata { name = _params.name }
        //
        { namespace = Some _params.namespace }
    }

in defaultConfigMap
