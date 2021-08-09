module "fluxcd" {
  source                  = "github.com/andreswebs/terraform-github-fluxcd-bootstrap"
  git_repository_name     = "k8s-fleet"
  git_branch              = "main"
  git_target_path         = "clusters/your-cluster"
  github_owner            = "your-github-name"
  github_deploy_key_title = "flux-your-cluster"
  create_deploy_key       = false
  flux_sync_secret_name   = "flux-system" ## --> name of the Kubernetes secret containing your deploy key
}