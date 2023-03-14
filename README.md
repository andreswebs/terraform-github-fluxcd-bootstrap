# terraform-github-fluxcd-bootstrap

Deploys the [FluxCD](https://fluxcd.io/docs/) toolkit on Kubernetes and stores the manifests in an existing GitHub repository.

**Note**: If using the default settings, this module will generate an SSH key pair and the public key will be added to the existing GitHub repository.
This key pair will be stored unencrypted in the Terraform state.
Make sure that only authorized users have direct access to the Terraform state.

It is highly recommended to use a remote state backend supporting encryption at rest. See [References](#references) for more information.

See the [examples](#usage) to use an externally generated key instead.

[//]: # (BEGIN_TF_DOCS)


## Usage

Example:

```hcl
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

module "fluxcd" {
  source                  = "github.com/andreswebs/terraform-github-fluxcd-bootstrap"
  git_repository_name     = "k8s-fleet"
  git_branch              = "main"
  git_target_path         = "clusters/your-cluster"
  github_owner            = "your-github-name"
  github_deploy_key_title = "flux-your-cluster"
}
```

If using an externally generated deploy key, first add the deploy public key to the GitHub repository (see [instructions](https://docs.github.com/en/developers/overview/managing-deploy-keys#setup-2)). Then create
a Kubernetes secret with the contents below:

```sh
kubectl create secret generic \
    flux-system \
    --namespace flux-system \
    --from-file=identity \
    --from-file=identity.pub \
    --from-literal=known_hosts="$(ssh-keyscan github.com)"
```

The key files must be named `identity` (private key) and `identity.pub` (public key).

After creating the secret, pass its name to the module:

```hcl
module "fluxcd" {
  source                  = "github.com/andreswebs/terraform-github-fluxcd-bootstrap"
  git_repository_name     = "k8s-fleet"
  git_branch              = "main"
  git_target_path         = "clusters/your-cluster"
  github_owner            = "your-github-name"
  github_deploy_key_title = "flux-your-cluster"
  create_deploy_key       = false
  flux_sync_secret_name   = "flux-system" ## --> name of the Kubernetes secret containing your deploy key
}
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_deploy_key"></a> [create\_deploy\_key](#input\_create\_deploy\_key) | Create the GitHub deploy key? | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the Kubernetes namespace? | `bool` | `true` | no |
| <a name="input_flux_image_pull_secrets"></a> [flux\_image\_pull\_secrets](#input\_flux\_image\_pull\_secrets) | Kubernetes secret name used for pulling the toolkit images from a private registry | `string` | `""` | no |
| <a name="input_flux_install_network_policy"></a> [flux\_install\_network\_policy](#input\_flux\_install\_network\_policy) | Deny ingress access to the toolkit controllers from other namespaces using network policies? | `bool` | `true` | no |
| <a name="input_flux_log_level"></a> [flux\_log\_level](#input\_flux\_log\_level) | Log level for Flux toolkit components | `string` | `"info"` | no |
| <a name="input_flux_registry"></a> [flux\_registry](#input\_flux\_registry) | Container registry from where the Flux toolkit images are pulled | `string` | `"ghcr.io/fluxcd"` | no |
| <a name="input_flux_resources_name"></a> [flux\_resources\_name](#input\_flux\_resources\_name) | The name of generated Kubernetes resources | `string` | `"flux-system"` | no |
| <a name="input_flux_sync_interval_minutes"></a> [flux\_sync\_interval\_minutes](#input\_flux\_sync\_interval\_minutes) | Sync interval in minutes | `number` | `1` | no |
| <a name="input_flux_sync_secret_name"></a> [flux\_sync\_secret\_name](#input\_flux\_sync\_secret\_name) | The name of the secret that is referenced by GitRepository as SecretRef | `string` | `"flux-system"` | no |
| <a name="input_flux_version"></a> [flux\_version](#input\_flux\_version) | FluxCD version; defaults to the latest available | `string` | `null` | no |
| <a name="input_flux_watch_all_namespaces"></a> [flux\_watch\_all\_namespaces](#input\_flux\_watch\_all\_namespaces) | Watch for custom resources in all namespaces? | `bool` | `true` | no |
| <a name="input_git_branch"></a> [git\_branch](#input\_git\_branch) | Git branch | `string` | `"main"` | no |
| <a name="input_git_repository_name"></a> [git\_repository\_name](#input\_git\_repository\_name) | Name of the Git repository to store the FluxCD manifests | `string` | n/a | yes |
| <a name="input_git_target_path"></a> [git\_target\_path](#input\_git\_target\_path) | Target path for storing FluxCD manifests in the Git repository | `string` | `"."` | no |
| <a name="input_github_deploy_key_readonly"></a> [github\_deploy\_key\_readonly](#input\_github\_deploy\_key\_readonly) | Set the GitHub deploy key as read-only? | `bool` | `true` | no |
| <a name="input_github_deploy_key_title"></a> [github\_deploy\_key\_title](#input\_github\_deploy\_key\_title) | GitHub deploy key title | `string` | `"flux"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub owner | `string` | n/a | yes |
| <a name="input_github_ssh_domain"></a> [github\_ssh\_domain](#input\_github\_ssh\_domain) | Domain to use for SSH to GitHub | `string` | `"github.com"` | no |
| <a name="input_github_ssh_known_hosts_file"></a> [github\_ssh\_known\_hosts\_file](#input\_github\_ssh\_known\_hosts\_file) | Path to a temporary file used to store GitHub's known hosts during the deployment | `string` | `"/tmp/github_known_hosts"` | no |
| <a name="input_k8s_cluster_domain"></a> [k8s\_cluster\_domain](#input\_k8s\_cluster\_domain) | The internal cluster domain | `string` | `"cluster.local"` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Name of the Kubernetes namespace where the resources will be deployed | `string` | `"flux-system"` | no |
| <a name="input_k8s_namespace_annotations"></a> [k8s\_namespace\_annotations](#input\_k8s\_namespace\_annotations) | Annotations to apply to the Kubernetes namespace when it is created | `map(string)` | `{}` | no |
| <a name="input_k8s_namespace_labels"></a> [k8s\_namespace\_labels](#input\_k8s\_namespace\_labels) | Labels to apply to the Kubernetes namespace when it is created | `map(string)` | `{}` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_key"></a> [deploy\_key](#output\_deploy\_key) | SSH key added to the GitHub repository |
| <a name="output_known_hosts"></a> [known\_hosts](#output\_known\_hosts) | Known hosts for GitHub's SSH domain |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The name (metadata.name) of the namespace |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_flux"></a> [flux](#provider\_flux) | ~> 0.25.1 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.16 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.2 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | ~> 0.25.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.16 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [github_repository_deploy_key.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_file.install](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.kustomize](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.sync](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [kubectl_manifest.install](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.flux](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.flux_sync_ssh](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [null_resource.k8s_namespace](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ssh_scan](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [flux_install.this](https://registry.terraform.io/providers/fluxcd/flux/latest/docs/data-sources/install) | data source |
| [flux_sync.this](https://registry.terraform.io/providers/fluxcd/flux/latest/docs/data-sources/sync) | data source |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |
| [kubectl_file_documents.install](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/file_documents) | data source |
| [kubectl_file_documents.sync](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/file_documents) | data source |
| [local_file.known_hosts](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

[//]: # (END_TF_DOCS)

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [Unlicense](UNLICENSE.md).

## References

<https://www.terraform.io/docs/language/state/sensitive-data.html>

<https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1>

## Acknowledgments

<https://github.com/kube-champ/terraform-k8s-flux-bootstrap>
