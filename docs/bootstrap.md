# GitHub Actions GCP Authentication

## Overview

Enables GitHub Actions deployment to Google Cloud Platform using Terragrunt with minimal manual steps.

For a detailed explanation of what this bootstrap does and the architecture, see the [catalog bootstrap documentation](https://github.com/ConsciousML/terragrunt-template-catalog-gcp/tree/main/bootstrap/README.md).

## Prerequisites

- GCP account with billing enabled
- GCP project with Owner or Editor permissions
- GitHub account with admin access to your repository
- Follow the [installation section](../README.md#installation)

## Configuration

Open `live/bootstrap/enable_tg_github_actions/terragrunt.stack.hcl` and update it according to the [configuration documentation](https://github.com/ConsciousML/terragrunt-template-catalog-gcp/blob/main/bootstrap/README.md#configuration)

Also update `live/bootstrap/project.hcl` and `live/bootstrap/region.hcl` with your GCP settings.

## Running the Bootstrap

1. Authenticate GitHub CLI:
   ```bash
   gh auth login --scopes "repo,admin:repo_hook"
   export TF_VAR_github_token="$(gh auth token)"
   ```

2. Deploy the bootstrap stack:
   ```bash
   cd live/bootstrap/enable_tg_github_actions
   terragrunt stack generate
   terragrunt stack run apply --backend-bootstrap --non-interactive
   ```

4. Verify setup:
   ```bash
   gh secret list
   ```

   You should see: `PROJECT_ID`, `WIF_PROVIDER`, `WIF_SERVICE_ACCOUNT`, `DEPLOY_KEY_TG_CATALOG`, `DEPLOY_KEY_TG_LIVE`

## Next Steps

- Review the [CI/CD workflow guide](ci_cd.md) to understand how to use the automated pipelines
- Create a test PR to verify CI/CD works correctly
