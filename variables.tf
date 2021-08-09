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

variable "create_namespace" {
  type        = bool
  description = "Create the Kubernetes namespace?"
  default     = true
}

variable "git_repository_name" {
  type        = string
  description = "Name of an existing Git repository to store the FluxCD manifests"
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

variable "flux_install_network_policy" {
  type        = bool
  default     = true
  description = "Deny ingress access to the toolkit controllers from other namespaces using network policies?"
}

variable "flux_version" {
  type        = string
  description = "FluxCD version; defaults to the latest available"
  default     = null
}

variable "flux_ssh_scan_url" {
  type        = string
  description = "URL to scan for GitHub's known hosts"
  default     = "github.com"
}

variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

variable "github_deploy_key_title" {
  type        = string
  default     = "flux-key"
  description = "GitHub deploy key title"
}

variable "ssh_known_hosts_file" {
  type        = string
  default     = "/tmp/known_hosts"
  description = "Path to a temporary file used to store GitHub's known hosts during the deployment"
}

variable "github_deploy_key_readonly" {
  type        = bool
  default     = true
  description = "Set the GitHub deploy key as read-only?"
}
