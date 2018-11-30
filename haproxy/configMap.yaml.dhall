let defaultConfigMap = ../dhall-kubernetes/default/io.k8s.api.core.v1.ConfigMap.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in
    defaultConfigMap { metadata = defaultMetadata { name = "haproxy-config" } }
    //
    { data = Some
        [ { mapKey = "backend-server-slots-increment", mapValue = "4" }
        , { mapKey = "ssl-dh-default-max-size", mapValue = "2048" }
        ]
    }

