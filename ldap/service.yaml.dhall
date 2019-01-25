../api/mkService.dhall (
    ../api/defaultService.dhall { name = "openldap", namespace = "ldap" }
    //
    { ports = Some [ ../api/defaultServicePort.dhall 636 // { name = Some "ldaps" } ] }
)
