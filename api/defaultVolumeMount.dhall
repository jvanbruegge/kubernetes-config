let VolumeMount = ../dhall-kubernetes/types/io.k8s.api.core.v1.VolumeMount.dhall

in \(_params : { mountPath : Text, name : Text }) ->
    _params
    //
    { mountPropagation = None Text
    , readOnly = None Bool
    , subPath = None Text
    } : VolumeMount
