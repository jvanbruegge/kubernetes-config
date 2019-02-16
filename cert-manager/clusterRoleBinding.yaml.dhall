let defaultClusterRoleBinding = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultClusterRoleBinding
    { metadata = defaultMetadata { name = "cert-manager" }
    , roleRef =
        { apiGroup = "rbac.authorization.k8s.io"
        , kind = "ClusterRole"
        , name = "cert-manager"
        }
    }
    //
    { subjects = Some
        [ { kind = "ServiceAccount"
          , name = "cert-manager"
          , namespace = Some "cert-manager"
          , apiGroup = None Text
          }
        ]
    }
