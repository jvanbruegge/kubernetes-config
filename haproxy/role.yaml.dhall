let defaultRole = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.Role.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultRule = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.PolicyRule.dhall

in defaultRole
    { metadata = defaultMetadata { name = "ingress-controller" } // { namespace = Some "haproxy" }
    , rules =
        [ defaultRule { verbs = ["get"] }
          //
          { resources = Some ["configmaps", "pods", "secrets", "namespaces"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["get", "update", "create"] }
          //
          { resources = Some ["configmaps", "endpoints"]
          , apiGroups = Some [""]
          }
        ]
    }
