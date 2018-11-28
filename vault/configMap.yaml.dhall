let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let config = ./vaultConfig.dhall

in
    defaultConfigMap { metadata = defaultMetadata { name = "ssl-config" } }
    //
    { data = Some [{ mapKey = "run.sh", mapValue = ./initSSL.sh.dhall config.sslPath }] }

