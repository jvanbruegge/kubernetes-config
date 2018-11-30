let Metadata = ../dhall-kubernetes/types/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in \(_params : { name : Text }) ->
    defaultMetadata { name = _params.name }
    //
    { labels = Some [{ mapKey = "app", mapValue = _params.name }] }
    : Metadata

