let map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map
let utils = ../api/utils.dhall

in ../api/defaultIngress.dhall
    { hostnames = map Text Text (utils.prepend "phpldapadmin.") ../hostnames.dhall
    , namespace = "phpldapadmin"
    , serviceName = "phpldapadmin"
    , servicePort = 443
    , annotations = Some
        [ { mapKey = "ingress.kubernetes.io/ssl-passthrough", mapValue = "true" }
        , { mapKey = "ingress.kubernetes.io/ssl-redirect", mapValue = "true" }
        ]
    }
