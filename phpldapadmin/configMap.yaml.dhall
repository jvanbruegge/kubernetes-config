let _env = ./env.yaml as Text

in ../api/defaultConfigMap.dhall { name = "config", namespace = "phpldapadmin" }
    //
    { data = Some
        [ { mapKey = "env.yaml", mapValue = _env }
        ]
    }

