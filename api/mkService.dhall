let Service = ../dhall-kubernetes/types/io.k8s.api.core.v1.Service.dhall
let defaultService = ../dhall-kubernetes/default/io.k8s.api.core.v1.Service.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.core.v1.ServiceSpec.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in \(s : ./Service.dhall) ->
    defaultService { metadata = defaultMetadata { name = s.name } }
    //
    { spec = Some (
        defaultSpec
        //
        { ports = s.ports
        , type = s.type
        , selector = Some [{ mapKey = "app", mapValue = s.name }]
        , externalIPs = s.externalIPs
        })
    } : Service
