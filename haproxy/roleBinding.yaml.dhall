let defaultRoleBinding = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.RoleBinding.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultRoleBinding
    { metadata = defaultMetadata { name = "ingress-controller" }
    , roleRef =
        { apiGroup = "rbac.authorization.k8s.io"
        , kind = "Role"
        , name = "ingress-controller"
        }
    }
    //
    { subjects = Some
        [ { kind = "ServiceAccount"
          , name = "ingress-controller"
          , namespace = None Text
          , apiGroup = None Text
          }
        , { kind = "User"
          , name = "ingress-controller"
          , apiGroup = Some "rbac.authorization.k8s.io"
          , namespace = None Text
          }
        ]
    }
