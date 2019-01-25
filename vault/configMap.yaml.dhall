../api/defaultConfigMap.dhall { name = "vault-config", namespace = "vault" }
    //
    { data = Some
        [ { mapKey = "runVault.sh", mapValue = ./runVault.sh.dhall } ]
    }

