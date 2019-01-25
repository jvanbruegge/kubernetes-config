../helpers/defaultLocalPersistentVolume.dhall
    { name = "ldap-data"
    , namespace = "ldap"
    , size = "1Gi"
    , directory = "ldap"
    }
