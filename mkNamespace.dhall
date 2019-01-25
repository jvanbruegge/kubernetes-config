let defaultMetadata = ./dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultNamespace = ./dhall-kubernetes/default/io.k8s.api.core.v1.Namespace.dhall

let mkNamespace = \(name : Text) ->
    defaultNamespace { metadata = defaultMetadata { name = name } }

in mkNamespace
