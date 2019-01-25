let defaultServiceAccount = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServiceAccount.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

let defaultServiceAccount = \(_params : { name : Text, namespace : Text }) ->
    defaultServiceAccount { metadata =
        defaultMetadata { name = _params.name }
        //
        { namespace = Some _params.namespace }
    }

in defaultServiceAccount
