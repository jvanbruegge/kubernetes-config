let config = ./config.dhall

in ../api/mkService.dhall (
    ../api/defaultService.dhall { name = "vault", namespace = "vault" }
    //
    { ports = Some
        [ ../api/defaultServicePort.dhall config.port
            // { name = Some "vault-port" }
        , ../api/defaultServicePort.dhall config.internalPort
            // { name = Some "internal-port" }
        ]
    }
)
