let map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map
let utils = ../api/utils.dhall

let config = ./config.dhall

in ../api/defaultIngress.dhall
    { hostnames = map Text Text (utils.prepend "vault.") ../hostnames.dhall
    , serviceName = "vault"
    , servicePort = config.port
    , annotations = Some
        [ { mapKey = "ingress.kubernetes.io/ssl-passthrough", mapValue = "true" }
        , { mapKey = "ingress.kubernetes.io/ssl-redirect", mapValue = "true" }
        ]
    }
