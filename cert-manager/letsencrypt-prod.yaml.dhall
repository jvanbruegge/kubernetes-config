{ apiVersion = "certmanager.k8s.io/v1alpha1"
, kind = "ClusterIssuer"
, metadata = { name = "letsencrypt-prod", namespace = "cert-manager" }
, spec = { amce =
    { server = "https://acme-v02.api.letsencrypt.org/directory"
    , email = "jan@vanbruegge.de"
    , privateKeySecretRef = { name = "letsencrypt-prod" }
    , http01 = { = }
    }
  }
}
