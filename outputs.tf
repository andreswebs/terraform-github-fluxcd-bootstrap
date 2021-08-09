output "namespace" {
  value       = local.k8s_namespace
  description = "The name (metadata.name) of the namespace"
}

output "deploy_key" {
  value       = tls_private_key.this
  description = "SSH key added to the GitHub repository"
}

output "known_hosts" {
  value = data.local_file.known_hosts.content
  description = "Known hosts for ${var.github_ssh_scan_domain}"
}
