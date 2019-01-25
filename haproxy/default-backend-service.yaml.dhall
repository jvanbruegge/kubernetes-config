../api/mkService.dhall (
    ../api/defaultService.dhall { name = "ingress-default-backend", namespace = "haproxy" }
    //
    { ports = Some [../api/defaultServicePort.dhall 8080] }
)
