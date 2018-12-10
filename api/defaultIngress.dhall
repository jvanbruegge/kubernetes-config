let IngressRule = ../dhall-kubernetes/types/io.k8s.api.extensions.v1beta1.IngressRule.dhall

let defaultIngress = ../dhall-kubernetes/default/io.k8s.api.extensions.v1beta1.Ingress.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.extensions.v1beta1.IngressSpec.dhall

let map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/List/map

let mkIngressRule =
    \(_params : { serviceName : Text, servicePort : Natural }) ->
    \(host : Text) ->
        ({ host = Some host
        , http = Some
            { paths =
                [ { path = Some "/"
                  , backend =
                      { serviceName = _params.serviceName
                      , servicePort = <Int = _params.servicePort | String : Text>
                      }
                  }
                ]
            }
        } : IngressRule)

in \(_params :
    { hostnames : List Text
    , serviceName : Text
    , servicePort : Natural
    , annotations : Optional (List { mapKey : Text, mapValue : Text })
    }) ->
        defaultIngress
            { metadata =
                defaultMetadata { name = _params.serviceName }
                //
                { annotations = _params.annotations }
            }
        //
        { spec = Some (
            defaultSpec
            //
            { rules = Some (map Text IngressRule
                (mkIngressRule
                    { serviceName = _params.serviceName, servicePort = _params.servicePort }
                )
                _params.hostnames
            ) }
        ) }
