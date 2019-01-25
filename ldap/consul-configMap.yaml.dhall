../helpers/mkConsulConfigMap.dhall
    { certFilenames = [{ subdir = None Text, name = "ldap.crt" }]
    , keyFilenames = [{ subdir = None Text, name = "ldap.key"}]
    , caFilenames = [{ subdir = None Text, name = "ca.crt"}]
    , rootCaFilenames = [] : List { subdir : Optional Text, name : Text }
    , subdomain = "ldap"
    , namespace = "ldap"
    }
