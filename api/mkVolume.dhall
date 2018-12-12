let Volume = ../dhall-kubernetes/types/io.k8s.api.core.v1.Volume.dhall
let ConfigMap = ../dhall-kubernetes/types/io.k8s.api.core.v1.ConfigMapVolumeSource.dhall
let PersistentVolumeClaim = ../dhall-kubernetes/types/io.k8s.api.core.v1.PersistentVolumeClaimVolumeSource.dhall

let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.Volume.dhall
let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMapVolumeSource.dhall

in \(v : ./SimpleVolume.dhall) ->
    let isPVC = merge
        { PVC = \(x : Text) -> True, ConfigMap = \(x : Text) -> False }
        v.volumeType

    let content = merge
        { PVC = \(x : Text) -> x, ConfigMap = \(x : Text) -> x }
        v.volumeType

    in
        defaultVolume { name = v.name }
        //
        (if isPVC then
          { persistentVolumeClaim = Some { claimName = content, readOnly = None Bool }
          , configMap = None ConfigMap
          }
        else
          { configMap = Some (defaultConfigMap // { name = Some content })
          , persistentVolumeClaim = None PersistentVolumeClaim
          }
        )
        : Volume
