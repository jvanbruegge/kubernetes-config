let defaultPort = ../api/defaultServicePort.dhall

in ../api/mkService.dhall (
    ../api/defaultService.dhall { name = "haproxy" }
    //
    { externalIPs = Some ["5.189.142.109", ../minikube-ip.dhall]
    , ports = Some
        [ defaultPort 80 // { name = Some "http" }
        , defaultPort 443 // { name = Some "https" }
        , defaultPort 1936 // { name = Some "stats" }
        , defaultPort 636 // { name = Some "ldaps" }
        ]
    }
)
