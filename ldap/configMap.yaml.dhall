let ldif = ./changePassword.ldif as Text
let treeLdif = ./changeTreePassword.ldif as Text
let command = ./command.sh as Text

in ../api/defaultConfigMap.dhall { name = "ldap-config", namespace = "ldap" }
    //
    { data = Some
        [ { mapKey = "chPassword.ldif", mapValue = ldif }
        , { mapKey = "chTreePassword.ldif", mapValue = treeLdif }
        , { mapKey = "command.sh", mapValue = command }
        ]
    }

