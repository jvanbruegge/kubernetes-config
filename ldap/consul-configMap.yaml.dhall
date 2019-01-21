../helpers/mkConsulConfigMap.dhall
    { certFilename = "ldap.crt"
    , keyFilename = "ldap.key"
    , caFilename = "ca.crt"
    , subdomain = "ldap"
    , namespace = "ldap"
    }
