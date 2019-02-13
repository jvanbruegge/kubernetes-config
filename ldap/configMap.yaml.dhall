let ldif = ./ldif/changePassword.ldif as Text
let treeLdif = ./ldif/changeTreePassword.ldif as Text
let objectclasses = ./ldif/objectclasses.ldif as Text
let dit = ./ldif/dit.ldif as Text
let command = ./command.sh as Text

in ../api/defaultConfigMap.dhall { name = "ldap-config", namespace = "ldap" }
    //
    { data = Some
        [ { mapKey = "chPassword.ldif", mapValue = ldif }
        , { mapKey = "chTreePassword.ldif", mapValue = treeLdif }
        , { mapKey = "objectclasses.ldif", mapValue = objectclasses }
        , { mapKey = "dit.ldif", mapValue = dit }
        , { mapKey = "command.sh", mapValue = command }
        ]
    }

