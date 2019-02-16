let defaultClusterRole = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.ClusterRole.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultRule = ../dhall-kubernetes/default/io.k8s.api.rbac.v1.PolicyRule.dhall

in defaultClusterRole
    { metadata = defaultMetadata { name = "cert-manager" }
    , rules =
        [ defaultRule { verbs = ["*"] }
          //
          { resources = Some ["certificates", "certificates/finalizers", "issuers", "clusterissuers", "orders", "orders/finalizers", "challenges"]
          , apiGroups = Some ["certmanager.k8s.io"]
          }

        , defaultRule { verbs = ["*"] }
          //
          { resources = Some ["configmaps", "secrets", "events", "services", "pods"]
          , apiGroups = Some [""]
          }

        , defaultRule { verbs = ["*"] }
          //
          { resources = Some ["ingresses"]
          , apiGroups = Some ["extensions"]
          }
        ]
    }
