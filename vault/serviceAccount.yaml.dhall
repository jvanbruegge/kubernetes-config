let defaultServiceAccount = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServiceAccount.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultServiceAccount { metadata = defaultMetadata { name = "vault-auth" } }
