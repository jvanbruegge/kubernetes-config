../api/defaultConfigMap.dhall { name = "haproxy-config", namespace = "haproxy" }
    //
    { data = Some
        [ { mapKey = "backend-server-slots-increment", mapValue = "4" }
        , { mapKey = "ssl-dh-default-max-size", mapValue = "2048" }
        ]
    }

