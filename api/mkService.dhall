let Service = ../dhall-kubernetes/types/io.k8s.api.core.v1.Service.dhall
let defaultService = ../dhall-kubernetes/default/io.k8s.api.core.v1.Service.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServiceSpec.dhall

in \(s : ./Service.dhall) ->
    let metadata = ./defaultMetadata.dhall { name = s.name }
    in
        defaultService { metadata = metadata }
        //
        { spec = Some (
            defaultSpec
            //
            { ports = s.ports
            , type = s.type
            , selector = Some [{ mapKey = "app", mapValue = s.name }]
            })
        } : Service
