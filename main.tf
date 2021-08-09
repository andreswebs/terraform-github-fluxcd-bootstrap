/**
 * Deploys the [FluxCD](https://fluxcd.io/docs/) toolkit on Kubernetes and stores the manifests in an existing GitHub repository.
 * 
 * **Note**: If using the default settings, this module will generate an SSH key pair and the public key will be added to the existing GitHub repository. 
 * This key pair will be stored unencrypted in the Terraform state.
 * Make sure that only authorized users have direct access to the Terraform state.
 *
 * It is highly recommended to use a remote state backend supporting encryption at rest. See [References](#references) for more information.
 *
 * See the [examples](#usage) to use an externally generated key instead.
 */

terraform {

  required_version = ">= 1.0.0"

  required_providers {

    github = {
      # source  = "integrations/github" ## has a bug, falling back to hashicorp/github
      source  = "hashicorp/github"
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

    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
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
    name        = local.k8s_namespace_norm
    labels      = var.k8s_namespace_labels
    annotations = var.k8s_namespace_annotations
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
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
  count     = var.create_deploy_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  deploy_key = var.create_deploy_key ? tls_private_key.this[0] : null  
}

resource "github_repository_deploy_key" "this" {
  count      = var.create_deploy_key ? 1 : 0
  title      = var.github_deploy_key_title
  repository = data.github_repository.this.name
  key        = local.deploy_key.public_key_openssh
  read_only  = var.github_deploy_key_readonly
}

resource "null_resource" "ssh_scan" {
  count = var.create_deploy_key ? 1 : 0

  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${var.github_ssh_domain} > ${var.github_ssh_known_hosts_file}"
  }

}

data "local_file" "known_hosts" {
  count      = var.create_deploy_key ? 1 : 0
  depends_on = [null_resource.ssh_scan]
  filename   = var.github_ssh_known_hosts_file
}

locals {
  known_hosts = var.create_deploy_key ? data.local_file.known_hosts[0].content : null
}

## end github repository

## flux install

data "flux_install" "this" {
  version              = var.flux_version
  namespace            = local.k8s_namespace
  target_path          = var.git_target_path
  network_policy       = var.flux_install_network_policy
  watch_all_namespaces = var.flux_watch_all_namespaces
  cluster_domain       = var.k8s_cluster_domain
  log_level            = var.flux_log_level
  registry             = var.flux_registry
  image_pull_secrets   = var.flux_image_pull_secrets

  ## TODO:
  # components = var.flux_install_components
  # components_extra = var.flux_install_components_extra
  # toleration_keys = var.flux_install_toleration_keys

}

data "kubectl_file_documents" "install" {
  content = data.flux_install.this.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
  }]
}

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
  name        = var.flux_resources_name
  namespace   = local.k8s_namespace
  url         = "ssh://git@${var.github_ssh_domain}/${var.github_owner}/${var.git_repository_name}.git"
  target_path = var.git_target_path
  branch      = var.git_branch
  interval    = var.flux_sync_interval_minutes
  secret      = var.flux_sync_secret_name
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

resource "kubernetes_secret" "flux_sync_ssh" {
  count      = var.create_deploy_key ? 1 : 0
  depends_on = [github_repository_deploy_key.this]

  metadata {
    name      = var.flux_sync_secret_name
    namespace = data.flux_sync.this.namespace
  }

  data = {
    "identity"     = local.deploy_key.private_key_pem
    "identity.pub" = local.deploy_key.public_key_openssh
    "known_hosts"  = local.known_hosts
  }
}

## end flux sync
