locals {
  # Automatically load account-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  gcp_project = local.project_vars.locals.project
  gcp_region   = local.region_vars.locals.region
}

remote_state {
  backend = "gcs"
  generate = "backend.tf"
  if_exists = "overwrite_terragrunt"
  config = {

    project = "${local.gcp_project}"
    location = "${local.gcp_region}"

    bucket = "tofu-state"
    prefix   = "${path_relative_to_include()}/tofu.tfstate"
    gcs_bucket_labels = {
      owner = "terragrunt"
      name  = "tofu_state_storage"
    }
  }
}

# Configure the GCP provider
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project = "${local.gcp_project}"
  region = "${local.gcp_region}"
}
EOF
}

catalog {
  urls = [
    "https://github.com/ConsciousML/terragrunt-template-stack",
  ]
}