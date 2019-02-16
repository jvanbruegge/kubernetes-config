let prelude = https://prelude.dhall-lang.org/package.dhall
  sha256:534e4a9e687ba74bfac71b30fc27aa269c0465087ef79bf483e876781602a454

let utils = ../api/utils.dhall

let mkUrls = \(sub : Text) ->
    prelude.`List`.map Text Text (utils.prepend sub) ../hostnames.dhall

in \(_params : { subdomain : Text, namespace : Text }) ->
    { apiVersion = "certmanager.k8s.io/v1alpha1"
    , kind = "Certificate"
    , metadata = { name = _params.subdomain, namespace = _params.namespace }
    , spec =
        { secretName = _params.subdomain ++ "-tls"
        , issuerRef =
            { name = "letsencrypt-prod"
            , kind = "ClusterIssuer"
            }
        , dnsNames = mkUrls _params.subdomain
        , acme = { config = [
            { http01 = { ingressClass = "haproxy" }
            , domains = mkUrls _params.subdomain
            }
          ]}
        }
    }
