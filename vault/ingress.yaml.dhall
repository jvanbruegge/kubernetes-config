let prelude = https://prelude.dhall-lang.org/package.dhall
  sha256:534e4a9e687ba74bfac71b30fc27aa269c0465087ef79bf483e876781602a454

let utils = ../api/utils.dhall

let config = ./config.dhall

in ../api/defaultIngress.dhall
    { hostnames = prelude.`List`.map Text Text (utils.prepend "vault.") ../hostnames.dhall
    , namespace = "vault"
    , serviceName = "vault"
    , servicePort = config.port
    , annotations = Some
        [ { mapKey = "ingress.kubernetes.io/ssl-passthrough", mapValue = "true" }
        , { mapKey = "ingress.kubernetes.io/ssl-redirect", mapValue = "true" }
        ]
    }
