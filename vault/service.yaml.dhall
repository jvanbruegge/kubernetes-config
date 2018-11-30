let config = ./config.dhall

in ../api/mkService.dhall (
    ../api/defaultService.dhall { name = "vault" }
    //
    { ports = Some [../api/defaultServicePort.dhall config.port] }
)
