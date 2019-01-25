let PersistentVolume = ../dhall-kubernetes/types/io.k8s.api.core.v1.PersistentVolume.dhall
let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolume.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolumeSpec.dhall
let defaultSelectorTerm = ../dhall-kubernetes/default/io.k8s.api.core.v1.NodeSelectorTerm.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let VolumeConfig =
    { name : Text
    , namespace : Text
    , size : Text
    , directory : Text
    }

let mkLocalPersistentVolume = \(_params : VolumeConfig) ->
    defaultVolume { metadata =
        defaultMetadata { name = _params.name }
        //
        { namespace = Some _params.namespace }
    }
    //
    { spec = Some (
        defaultSpec
        //
        { capacity = Some [{ mapKey = "storage", mapValue = _params.size }]
        , accessModes = Some ["ReadWriteOnce"]
        , persistentVolumeReclaimPolicy = Some "Retain"
        , storageClassName = Some "local-storage"
        , local = Some { path = "/data/" ++ _params.directory }
        , nodeAffinity = Some
            { required = Some
                { nodeSelectorTerms =
                    [defaultSelectorTerm
                    //
                    { matchExpressions = Some [
                        { key = "kubernetes.io/hostname"
                        , operator = "In"
                        , values = Some ../server-hostnames.dhall
                        }]
                    }]
                }
            }
        })
    } : PersistentVolume

in mkLocalPersistentVolume
