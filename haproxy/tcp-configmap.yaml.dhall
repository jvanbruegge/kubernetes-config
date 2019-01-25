../api/defaultConfigMap.dhall { name = "haproxy-tcp-config", namespace = "haproxy" }
    //
    { data = Some [ { mapKey = "636", mapValue = "ldap/openldap:636" } ] }
