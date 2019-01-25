../helpers/defaultLocalPersistentVolume.dhall
    { name = "vault-data"
    , namespace = "vault"
    , size = "1Gi"
    , directory = "vault"
    }
