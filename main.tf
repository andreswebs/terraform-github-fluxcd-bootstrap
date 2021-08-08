/**
 * Deploys the FluxCD toolkit on Kubernetes and stores the manifests in an existing GitHub repository.
 * 
 * An SSH public key will be added to the existing GitHub repository.
 * 
 * **Note**: This module will generate an SSH keypair and it will be stored unencrypted in the Terraform state.
 * Make sure to that only authorized users have direct access to the Terraform state.
 *
 * It is highly recommended to use a remote state backend supporting encryption at rest.
 */

terraform {

  required_version = ">= 1.0.0"

  required_providers {

    github = {
      source  = "integrations/github"
      version = ">= 4.13.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.2.2"
    }

  }
}

## namespace

locals {
  k8s_namespace_norm = var.k8s_namespace == "" || var.k8s_namespace == null ? "flux-system" : var.k8s_namespace
}

resource "kubernetes_namespace" "flux" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = local.k8s_namespace_norm
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

locals {
  k8s_namespace = var.create_namespace ? kubernetes_namespace.flux[0].metadata[0].name : local.k8s_namespace_norm
}

resource "null_resource" "k8s_namespace" {
  triggers = {
    "name" = local.k8s_namespace
  }
}

## end namespace

## github repository

data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.git_repository_name}"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "github_repository_deploy_key" "this" {
  title      = var.github_deploy_key_title
  repository = data.github_repository.this.name
  key        = tls_private_key.this.public_key_openssh
  read_only  = var.github_deploy_key_readonly
}

resource "null_resource" "ssh_scan" {

  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${var.flux_ssh_scan_url} > ${var.ssh_known_hosts_file}"
  }

}

data "local_file" "known_hosts" {
  depends_on = [null_resource.ssh_scan]
  filename = var.ssh_known_hosts_file
}

## end github repository

## flux install

data "flux_install" "this" {
  target_path    = var.git_target_path
  network_policy = var.flux_install_network_policy
  version        = var.flux_version
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
  }]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "install" {
  depends_on = [null_resource.k8s_namespace]
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

resource "github_repository_file" "install" {
  repository          = data.github_repository.this.name
  file                = data.flux_install.this.path
  content             = data.flux_install.this.content
  branch              = var.git_branch
  overwrite_on_create = true
}

## end flux install

## flux sync

data "flux_sync" "this" {
  url         = "ssh://git@github.com/${var.github_owner}/${var.git_repository_name}.git"
  target_path = var.git_target_path
  branch      = var.git_branch
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.this.content
}

locals {
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
  }]
}

resource "kubectl_manifest" "sync" {
  depends_on = [null_resource.k8s_namespace]
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

resource "github_repository_file" "sync" {
  repository          = data.github_repository.this.name
  file                = data.flux_sync.this.path
  content             = data.flux_sync.this.content
  branch              = var.git_branch
  overwrite_on_create = true
}

resource "github_repository_file" "kustomize" {
  repository          = data.github_repository.this.name
  file                = data.flux_sync.this.kustomize_path
  content             = data.flux_sync.this.kustomize_content
  branch              = var.git_branch
  overwrite_on_create = true
}

resource "kubernetes_secret" "sync_ssh" {
  
  metadata {
    name      = data.flux_sync.this.name
    namespace = data.flux_sync.this.namespace
  }

  data = {
    "identity"     = tls_private_key.this.private_key_pem
    "identity.pub" = tls_private_key.this.public_key_openssh
    "known_hosts"  = data.local_file.known_hosts.content
  }
}

## end flux sync
