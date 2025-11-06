locals {
  version = "v0.1.0"
}

stack "enable_tg_github_actions" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-gcp//stacks/enable_tg_github_actions?ref=${local.version}"
  path   = "enable_tg_github_actions"

  values = {
    # Change these values
    github_username    = "ConsciousML"
    current_repository = "terragrunt-template-live-gcp"

    # Set github_token via environment variable: export TF_VAR_github_token="your_token_here"
    github_token = get_env("TF_VAR_github_token")

    # TODO: change version to `main` before merge
    version = local.version

    # Workload Identity Federation configuration
    wif_pool_id                      = "gh-pool"
    wif_display_name                 = "GitHub Pool Live"
    wif_description                  = "Identity pool for GitHub deployments on the live Terragrunt repository"
    wif_service_account_id           = "gh-actions-live"
    wif_service_account_display_name = "GitHub Actions Service Account"
    wif_service_account_description  = "Service account for GitHub Actions workflows"
    wif_iam_roles = [
      "roles/viewer",                          # Basic read access to all resources
      "roles/storage.admin",                   # Full access to Cloud Storage (for Terraform state)
      "roles/compute.networkAdmin",            # Create/manage VPCs, subnets, global addresses
      "roles/compute.instanceAdmin.v1",        # Create/manage GCE instances
      "roles/servicenetworking.networksAdmin", # Create private service connections
      "roles/serviceusage.serviceUsageAdmin",  # Enable/disable GCP APIs
      "roles/iam.serviceAccountUser"           # Use default Compute Engine service account
    ]

    # Deploy key configuration
    deploy_key_repositories = ["terragrunt-template-catalog-gcp", "terragrunt-template-live-gcp"]
    deploy_key_secret_names = ["DEPLOY_KEY_TG_CATALOG", "DEPLOY_KEY_TG_LIVE"]
    deploy_key_title        = "Terragrunt Live Deploy Key"
  }
}