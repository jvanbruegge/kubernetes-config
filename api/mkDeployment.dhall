let Deployment = ../dhall-kubernetes/types/io.k8s.api.apps.v1.Deployment.dhall

let defaultDeployment = ../dhall-kubernetes/default/io.k8s.api.apps.v1.Deployment.dhall
let defaultSpec = ../dhall-kubernetes/default/io.k8s.api.apps.v1.DeploymentSpec.dhall

in \(deployment: ./SimpleDeployment.dhall) ->
    let metadata = ./defaultMetadata.dhall { name = deployment.name }

    in
        defaultDeployment { metadata = metadata }
        //
        { spec = Some (
            defaultSpec
                { selector = ./mkSelector.dhall deployment
                , template = ./mkTemplate.dhall metadata deployment
                }
            //
            { replicas = Some deployment.replicas })
        } : Deployment
