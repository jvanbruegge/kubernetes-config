let PersistentVolume = ../dhall-kubernetes/types/io.k8s.api.core.v1.PersistentVolume.dhall
let defaultVolume = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolume.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.PersistentVolumeSpec.dhall
let defaultSelectorTerm = ../dhall-kubernetes/default/io.k8s.api.core.v1.NodeSelectorTerm.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let name = "persistent-data"

in
    defaultVolume { metadata = defaultMetadata { name = name } }
    //
    { spec = Some (
        defaultSpec
        //
        { capacity = Some [{ mapKey = "storage", mapValue = "200Gi" }]
        , accessModes = Some ["ReadWriteOnce"]
        , persistentVolumeReclaimPolicy = Some "Retain"
        , storageClassName = Some "local-storage"
        , local = Some { path = "/data" }
        , nodeAffinity = Some
            { required = Some
                { nodeSelectorTerms =
                    [defaultSelectorTerm
                    //
                    { matchExpressions = Some [
                        { key = "kubernetes.io/hostname"
                        , operator = "In"
                        , values = Some ["vmd14423.contaboserver.net", "minikube"]
                        }]
                    }]
                }
            }
        })
    } : PersistentVolume
