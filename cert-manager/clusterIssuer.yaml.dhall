let defaultCustomResourceDefinition = ../dhall-kubernetes/default/io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1beta1.CustomResourceDefinition.dhall
let defaultCustomResourceSpec = ../dhall-kubernetes/default/io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1beta1.CustomResourceDefinitionSpec.dhall
let defaultNames = ../dhall-kubernetes/default/io.k8s.apiextensions-apiserver.pkg.apis.apiextensions.v1beta1.CustomResourceDefinitionNames.dhall
let defaultMetadata = ../dhall-kubernetes/default/io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta.dhall

in defaultCustomResourceDefinition
		{ metadata =
			defaultMetadata { name = "clusterissuers.certmanager.k8s.io" }
			//
			{ namespace = Some "cert-manager" }
		}
	//
	{ spec = Some (
		defaultCustomResourceSpec
			{ group = "certmanager.k8s.io"
			, scope = "Cluster"
			, names = defaultNames { kind = "ClusterIssuer", plural = "clusterissuers" }
			}
        // { version = Some "v1alpha1" }
		)
	}

