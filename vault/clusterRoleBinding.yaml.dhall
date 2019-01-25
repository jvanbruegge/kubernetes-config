let defaultClusterRoleBinding = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultClusterRoleBinding
    { metadata = defaultMetadata { name = "tokenreview" } // { namespace = Some "vault" }
    , roleRef =
        { apiGroup = "rbac.authorization.k8s.io"
        , kind = "ClusterRole"
        , name = "system:auth-delegator"
        }
    }
    //
    { subjects = Some
        [ { kind = "ServiceAccount"
          , name = "vault-auth"
          , namespace = Some "vault"
          , apiGroup = None Text
          }
        ]
    }
