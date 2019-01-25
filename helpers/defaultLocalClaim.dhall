let PersistentVolumeClaim = ../dhall-kubernetes/types/io.k8s.api.core.v1.PersistentVolumeClaim.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultVolumeClaim = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolumeClaim.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolumeClaimSpec.dhall
let defaultResources = ../dhall-kubernetes/default/io.k8s.api.core.v1.ResourceRequirements.dhall

let ClaimOptions =
  { name : Text
  , namespace : Text
  , size : Text
  }

let mkLocalClaim = \(_params : ClaimOptions) ->
    defaultVolumeClaim { metadata =
        defaultMetadata { name = _params.name }
        //
        { namespace = Some _params.namespace }
    }
    //
    { spec = Some (
        defaultSpec
        //
        { accessModes = Some ["ReadWriteOnce"]
        , volumeMode = Some "Filesystem"
        , storageClassName = Some "local-storage"
        , resources = Some (
            defaultResources
            //
            { requests = Some [{ mapKey = "storage", mapValue = _params.size }] }
            )
        })
    } : PersistentVolumeClaim

in mkLocalClaim
