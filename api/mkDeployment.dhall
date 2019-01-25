let Deployment = ../dhall-kubernetes/types/io.k8s.api.apps.v1.Deployment.dhall

let defaultDeployment = ../dhall-kubernetes/default/io.k8s.api.apps.v1.Deployment.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.apps.v1.DeploymentSpec.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in \(deployment: ./SimpleDeployment.dhall) ->
    let m = { name = deployment.name }

    in defaultDeployment { metadata = defaultMetadata m // { namespace = Some deployment.namespace } }
    //
    { spec = Some (
        defaultSpec
            { selector = ./mkSelector.dhall deployment
            , template = ./mkTemplate.dhall (./defaultMetadata.dhall m) deployment
            }
        //
        { replicas = Some deployment.replicas })
    } : Deployment
