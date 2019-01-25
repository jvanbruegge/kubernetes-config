../helpers/mkConsulConfigMap.dhall
    { certFilenames =
        [ { subdir = Some "ldap", name = "ldap-client.crt" }
        , { subdir = Some "https", name = "phpldapadmin.crt" }
        ]
    , keyFilenames  =
        [ { subdir = Some "ldap", name = "ldap-client.key" }
        , { subdir = Some "https", name = "phpldapadmin.key" }
        ]
    , caFilenames = [ { subdir = Some "https", name = "ca.crt" } ]
    , rootCaFilenames = [ { subdir = Some "ldap", name = "ldap-ca.crt" } ]
    , namespace = "phpldapadmin"
    , subdomain = "phpldapadmin"
    }
