let SecurityContext = ../dhall-kubernetes/types/io.k8s.api.core.v1.SecurityContext.dhall
let Probe = ../dhall-kubernetes/types/io.k8s.api.core.v1.Probe.dhall

let defaultSecurityContext = ../dhall-kubernetes/default/io.k8s.api.core.v1.SecurityContext.dhall
let defaultProbe = ../dhall-kubernetes/default/io.k8s.api.core.v1.Probe.dhall
let defaultHttpGet = ../dhall-kubernetes/default/io.k8s.api.core.v1.HTTPGetAction.dhall

let fromMaybe : forall(a : Type) -> a -> Optional a -> a
    = \(a : Type) -> \(x : a) -> \(xs : Optional a) -> Optional/fold a xs a (\(v : a) -> v) x

let addCapabilities : List Text -> SecurityContext
    = \(xs : List Text) ->
        defaultSecurityContext
        //
        { capabilities = Some
            { drop = None (List Text)
            , add = Some xs
            }
        }

let getProbe : { path : Text, port : Natural, scheme : Text } -> Probe
    = \(_params : { path : Text, port : Natural, scheme : Text }) ->
        defaultProbe
        //
        { httpGet = Some (
            defaultHttpGet { port = <Int = _params.port | String : Text> }
            //
            { path = Some _params.path
            , scheme = Some _params.scheme
            })
        } : Probe

let prepend : Text -> Text -> Text
    = \(prefix : Text) -> \(str : Text) -> prefix ++ str

in
    { fromMaybe = fromMaybe
    , addCapabilities = addCapabilities
    , httpGetProbe = getProbe
    , prepend = prepend
    }
