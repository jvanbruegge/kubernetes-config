let defaultLabels = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.LabelSelector.dhall

in \(_param : ./SimpleDeployment.dhall) ->
    defaultLabels
    //
    { matchLabels = Some [{ mapKey = "app", mapValue = _param.name }] }
