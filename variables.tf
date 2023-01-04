variable "k8s_namespace" {
  type        = string
  default     = "flux-system"
  description = "Name of the Kubernetes namespace where the resources will be deployed"
}

variable "k8s_namespace_labels" {
  type        = map(string)
  default     = {}
  description = "Labels to apply to the Kubernetes namespace when it is created"
}

variable "k8s_namespace_annotations" {
  type        = map(string)
  default     = {}
  description = "Annotations to apply to the Kubernetes namespace when it is created"
}

variable "k8s_cluster_domain" {
  type        = string
  default     = "cluster.local"
  description = "The internal cluster domain"
}

## github

variable "git_repository_name" {
  type        = string
  description = "Name of the Git repository to store the FluxCD manifests"
}

variable "git_branch" {
  type        = string
  default     = "main"
  description = "Git branch"
}

variable "git_target_path" {
  type        = string
  default     = "."
  description = "Target path for storing FluxCD manifests in the Git repository"
}

variable "github_ssh_domain" {
  type        = string
  description = "Domain to use for SSH to GitHub"
  default     = "github.com"
}

variable "github_ssh_known_hosts_file" {
  type        = string
  default     = "/tmp/github_known_hosts"
  description = "Path to a temporary file used to store GitHub's known hosts during the deployment"
}

variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

variable "github_deploy_key_title" {
  type        = string
  default     = "flux"
  description = "GitHub deploy key title"
}

variable "github_deploy_key_readonly" {
  type        = bool
  default     = true
  description = "Set the GitHub deploy key as read-only?"
}

## end github

## flux

variable "flux_version" {
  type        = string
  description = "FluxCD version; defaults to the latest available"
  default     = null
}

variable "flux_watch_all_namespaces" {
  type        = bool
  default     = true
  description = "Watch for custom resources in all namespaces?"
}

variable "flux_log_level" {
  type        = string
  default     = "info"
  description = "Log level for Flux toolkit components"
}

variable "flux_registry" {
  type        = string
  default     = "ghcr.io/fluxcd"
  description = "Container registry from where the Flux toolkit images are pulled"
}

variable "flux_resources_name" {
  type        = string
  default     = "flux-system"
  description = "The name of generated Kubernetes resources"
}

variable "flux_image_pull_secrets" {
  type        = string
  default     = ""
  description = "Kubernetes secret name used for pulling the toolkit images from a private registry"
}

variable "flux_install_network_policy" {
  type        = bool
  default     = true
  description = "Deny ingress access to the toolkit controllers from other namespaces using network policies?"
}

variable "flux_sync_secret_name" {
  type        = string
  default     = "flux-system" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "The name of the secret that is referenced by GitRepository as SecretRef"
}

variable "flux_sync_interval_minutes" {
  type        = number
  default     = 1
  description = "Sync interval in minutes"
}

## end flux

## conditional resources

variable "create_namespace" {
  type        = bool
  description = "Create the Kubernetes namespace?"
  default     = true
}

variable "create_deploy_key" {
  type        = bool
  description = "Create the GitHub deploy key?"
  default     = true
}

## end conditional resources
