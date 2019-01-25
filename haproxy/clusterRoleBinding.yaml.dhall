let defaultClusterRoleBinding = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.ClusterRoleBinding.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultClusterRoleBinding
    { metadata = defaultMetadata { name = "ingress-controller" } // { namespace = Some "haproxy" }
    , roleRef =
        { apiGroup = "rbac.authorization.k8s.io"
        , kind = "ClusterRole"
        , name = "ingress-controller"
        }
    }
    //
    { subjects = Some
        [ { kind = "ServiceAccount"
          , name = "ingress-controller"
          , namespace = Some "haproxy"
          , apiGroup = None Text
          }
        , { kind = "User"
          , name = "ingress-controller"
          , namespace = Some "haproxy"
          , apiGroup = Some "rbac.authorization.k8s.io"
          }
        ]
    }
