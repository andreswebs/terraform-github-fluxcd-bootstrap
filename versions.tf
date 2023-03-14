terraform {

  required_version = "~> 1.3"

  required_providers {

    github = {
      source  = "integrations/github" ## has a bug, falling back to hashicorp/github
      version = "~> 5.0"
      # source  = "hashicorp/github"
      # version = ">= 4.13.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.25.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

  }
}
