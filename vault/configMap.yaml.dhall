let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in
    defaultConfigMap { metadata = defaultMetadata { name = "vault-config" } }
    //
    { data = Some
        [ { mapKey = "runVault.sh", mapValue = ./runVault.sh.dhall }
        ]
    }

