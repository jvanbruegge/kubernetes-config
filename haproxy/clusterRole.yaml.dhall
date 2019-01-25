let defaultClusterRole = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.ClusterRole.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultRule = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.PolicyRule.dhall

in defaultClusterRole
    { metadata = defaultMetadata { name = "ingress-controller" } // { namespace = Some "haproxy" }
    , rules =
        [ defaultRule { verbs = ["list", "watch"] }
          //
          { resources = Some ["configmaps", "endpoints", "nodes", "pods", "secrets"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["get"] }
          //
          { resources = Some ["nodes"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["get", "list", "watch"] }
          //
          { resources = Some ["services"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["create", "patch"] }
          //
          { resources = Some ["events"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["get", "list", "watch"] }
          //
          { resources = Some ["ingresses"]
          , apiGroups = Some ["extensions"]
          }

        , defaultRule { verbs = ["update"] }
          //
          { resources = Some ["ingresses/status"]
          , apiGroups = Some ["extensions"]
          }
        ]
    }
