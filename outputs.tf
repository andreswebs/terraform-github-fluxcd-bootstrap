output "namespace" {
  value       = local.k8s_namespace
  description = "The name (metadata.name) of the namespace"
}

output "deploy_key" {
  value       = local.deploy_key
  description = "SSH key added to the GitHub repository"
}

output "known_hosts" {
  value       = local.known_hosts
  description = "Known hosts for GitHub's SSH domain"
}
