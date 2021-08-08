# terraform-github-fluxcd-bootstrap

[//]: # (BEGIN_TF_DOCS)
Deploys the FluxCD toolkit on Kubernetes and stores the manifests in an existing GitHub repository.

An SSH public key will be added to the existing GitHub repository.

**Note**: This module will generate an SSH keypair and it will be stored unencrypted in the Terraform state.
Make sure to that only authorized users have direct access to the Terraform state.

It is highly recommended to use a remote state backend supporting encryption at rest.

## Usage

Example:

```hcl
module "fluxcd_resources" {
  source                  = "github.com/andreswebs/terraform-github-fluxcd-bootstrap"
  git_repository_name     = "k8s-fleet"
  git_branch              = "main"
  git_target_path         = "clusters/your-cluster"
  github_owner            = "your-github-name"
  github_deploy_key_title = "flux-your-cluster"
}
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the Kubernetes namespace? | `bool` | `true` | no |
| <a name="input_flux_install_network_policy"></a> [flux\_install\_network\_policy](#input\_flux\_install\_network\_policy) | Deny ingress access to the toolkit controllers from other namespaces using network policies? | `bool` | `true` | no |
| <a name="input_flux_ssh_scan_url"></a> [flux\_ssh\_scan\_url](#input\_flux\_ssh\_scan\_url) | URL to scan for GitHub's known hosts | `string` | `"github.com"` | no |
| <a name="input_flux_version"></a> [flux\_version](#input\_flux\_version) | FluxCD version; defaults to the latest available | `string` | `null` | no |
| <a name="input_git_branch"></a> [git\_branch](#input\_git\_branch) | Git branch | `string` | `"main"` | no |
| <a name="input_git_repository_name"></a> [git\_repository\_name](#input\_git\_repository\_name) | Name of an existing Git repository to store the FluxCD manifests | `string` | n/a | yes |
| <a name="input_git_target_path"></a> [git\_target\_path](#input\_git\_target\_path) | Target path for storing FluxCD manifests in the Git repository | `string` | `"."` | no |
| <a name="input_github_deploy_key_readonly"></a> [github\_deploy\_key\_readonly](#input\_github\_deploy\_key\_readonly) | Set the GitHub deploy key as read-only? | `bool` | `true` | no |
| <a name="input_github_deploy_key_title"></a> [github\_deploy\_key\_title](#input\_github\_deploy\_key\_title) | GitHub deploy key title | `string` | `"flux-key"` | no |
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub owner | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Name of the Kubernetes namespace where the resources will be deployed | `string` | `"flux-system"` | no |
| <a name="input_ssh_known_hosts_file"></a> [ssh\_known\_hosts\_file](#input\_ssh\_known\_hosts\_file) | Path to a temporary file storing GitHub's known hosts | `string` | `"/tmp/known_hosts"` | no |

## Modules

No modules.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_key"></a> [deploy\_key](#output\_deploy\_key) | SSH key added to the GitHub repository |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The name (metadata.name) of the namespace |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_flux"></a> [flux](#provider\_flux) | >= 0.2.2 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.13.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.11.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.4.1 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.1.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | >= 0.2.2 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.13.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.11.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.4.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1.0 |

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
| [kubernetes_secret.sync_ssh](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
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
