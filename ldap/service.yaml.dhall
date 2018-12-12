../api/mkService.dhall (
    ../api/defaultService.dhall { name = "openldap" }
    //
    { ports = Some [ ../api/defaultServicePort.dhall 636 // { name = Some "ldaps" } ] }
)
