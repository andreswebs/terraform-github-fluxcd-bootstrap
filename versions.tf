terraform {

  required_version = ">= 1.1.0"

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