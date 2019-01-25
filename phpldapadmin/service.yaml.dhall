../api/mkService.dhall (
    ../api/defaultService.dhall { name = "phpldapadmin", namespace = "phpldapadmin" }
    //
    { ports = Some [ ../api/defaultServicePort.dhall 443 // { name = Some "https" } ] }
)
