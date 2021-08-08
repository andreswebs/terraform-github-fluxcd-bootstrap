output "namespace" {
  value       = local.k8s_namespace
  description = "The name (metadata.name) of the namespace"
}

output "deploy_key" {
  value = tls_private_key.this
  description = "SSH key added to the GitHub repository"
}
