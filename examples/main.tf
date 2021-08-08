provider "github" {
  token = var.github_token # or `GITHUB_TOKEN`
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

module "fluxcd" {
  source                  = "github.com/andreswebs/terraform-github-fluxcd-bootstrap"
  git_repository_name     = "k8s-fleet"
  git_branch              = "main"
  git_target_path         = "clusters/your-cluster"
  github_owner            = "your-github-name"
  github_deploy_key_title = "flux-your-cluster"
}