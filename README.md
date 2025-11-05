# Terragrunt Template Live GCP

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/ConsciousML/terragrunt-template-live-gcp.svg?style=flat)]()
[![CI](https://github.com/ConsciousML/terragrunt-template-live-gcp/actions/workflows/ci.yaml/badge.svg)](https://github.com/ConsciousML/terragrunt-template-live-gcp/actions/workflows/ci.yaml)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A prod-ready Terragrunt Template for deploying multi-environment IaC on Google Cloud Platform (GCP).

## Catalog vs Live Infrastructure

This is a **live repository** for deploying infrastructure across multiple environments.

This IaC production toolkit follows [Gruntwork's official patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example) by using two template repositories:
- **Catalog repository**: Defines **what** can be deployed (reusable components: [modules, units, and stacks](https://github.com/ConsciousML/terragrunt-template-catalog-gcp))
- **This repository** (live): Defines **where** and **how** catalog components are deployed in `dev`, `staging`, and `prod` environments with CI/CD


## What's Inside

- Multi-environment IaC support
- [CI](.github/workflows/ci.yaml) (on PR): Runs `terragrunt plan` on each environment, uploads output plan to PR, deploys on the staging environment, runs some tests, and destroys.
- [CD](.github/workflows/cd.yaml) (on push `main`): Automatically deploys on `prod`
- [Bootstrap pipeline](live/bootstrap/enable_tg_github_actions/) to automatically authenticate GitHub Actions with GCP.

## Getting Started

### Prerequisites
- GCP account with billing enabled
- GitHub account
- GCP IAM permissions to create service accounts and workload identity pools

### Fork the Repository

1. Click on `Use this template` to create your own repository
2. Clone your new repository locally
3. Replace all occurrences of `ConsciousML` with your GitHub organization/username:
   - In `live/root.hcl` under the `catalog` block
   - In stack source URLs (if you're using your own catalog fork)

### Installation

**Option 1: Use mise (recommended)**

First install mise by following their [getting started guide](https://mise.jdx.dev/getting-started.html), then:
```bash
mise install
```

This installs the required versions of:
- OpenTofu 1.9.1
- Terragrunt 0.84.1
- Go 1.24
- Python 3.13.1

**Option 2: Install Tools Manually**
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Go](https://go.dev/doc/install)
- [Python 3.13.1](https://www.python.org/downloads/)
- [GitHub CLI](https://github.com/cli/cli#installation)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)

See [mise.toml](./mise.toml) for specific versions.

### Configure GCP Settings

1. Authenticate with GCP:
```bash
gcloud auth login
gcloud auth application-default login
```

2. List your GCP projects:
```bash
gcloud projects list
```

3. Set your default project:
```bash
gcloud config set project YOUR_PROJECT_ID
```

4. Update environment configuration files with your GCP project ID and region:

Edit `project.hcl` in each environment directory:
```hcl
# live/dev/project.hcl
locals {
  project = "your-dev-project-id"
}
```

Edit `region.hcl` in each environment directory:
```hcl
# live/dev/region.hcl
locals {
  region = "us-central1"  # Or your preferred region
}
```

Repeat for `live/staging/` and `live/prod/` directories.

### Bootstrap GitHub Actions Authentication

**Important**: Run this **once** after creating your repository to set up secure authentication between GitHub Actions and GCP.

This bootstrap process creates:
- Workload Identity Federation pool and provider
- Service account for GitHub Actions (`gh-actions-live`)
- Required IAM roles for Terragrunt operations
- GitHub secrets for CI/CD authentication
- Deploy keys for accessing private catalog repositories

Follow the detailed instructions in the [bootstrap README](https://github.com/ConsciousML/terragrunt-template-catalog-gcp/tree/main/bootstrap/enable_tg_github_actions).

**Quick summary:**
```bash
cd bootstrap/enable_tg_github_actions/
# Update terragrunt.stack.hcl with your settings
gh auth login --scopes "repo,admin:repo_hook"
export TF_VAR_github_token="$(gh auth token)"
terragrunt stack generate
terragrunt stack run apply --backend-bootstrap --non-interactive
```

After bootstrap completes, your GitHub Actions workflows will be able to authenticate to GCP without storing any credentials.

## Deployment Workflow

### Local Deployment (Development/Testing)

Deploy to the dev environment locally:

```bash
cd live/dev
terragrunt stack generate
terragrunt run --all init --backend-bootstrap --non-interactive
terragrunt run --all apply --non-interactive
```

To destroy the infrastructure:
```bash
cd live/dev
terragrunt stack generate
terragrunt run --all destroy --non-interactive
```

### Viewing the Terraform Plan

Before applying changes, you can preview what will be created/modified:

```bash
cd live/dev
terragrunt stack generate
terragrunt run --all plan
```

### Deploying to Different Environments

The same commands work for any environment, just change the directory:

```bash
# Staging
cd live/staging
terragrunt stack generate
terragrunt run --all apply --non-interactive

# Production (be careful!)
cd live/prod
terragrunt stack generate
terragrunt run --all apply --non-interactive
```

### Updating Catalog Versions

Each stack references a specific version of the catalog. To update:

1. Edit the `terragrunt.stack.hcl` file in your environment:
```hcl
locals {
  version = "v0.0.3"  # Update to new version
}

stack "vpc_gce" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-gcp//stacks/vpc_gce?ref=${local.version}"
  # ... rest of configuration
}
```

2. Test the update:
```bash
cd live/dev
terragrunt stack generate
terragrunt run --all plan
```

3. Apply if the plan looks correct:
```bash
terragrunt run --all apply --non-interactive
```

## CI/CD Pipelines

This repository includes production-ready GitHub Actions workflows that automate validation, testing, and deployment.

### Continuous Integration (CI)

**Trigger**: Pull requests to `main` branch

**What it does:**
1. **HCL Format Check**: Validates Terragrunt/HCL file formatting
2. **Validate & Plan**: Runs on all environments (dev, staging, prod) in parallel
   - Generates stack configurations
   - Initializes Terragrunt with backend bootstrapping
   - Validates Terraform configuration
   - Creates Terraform plans
3. **Terratest**: Runs infrastructure tests (requires `run-terratest` label)
4. **Plan Review**: Comments on PR with production plan artifact for review

**Authentication**: Uses Workload Identity Federation (WIF) configured during bootstrap

**How to use:**
1. Create a feature branch
2. Make your infrastructure changes
3. Open a pull request
4. Review the automated validation and plans
5. Add `run-terratest` label to trigger full infrastructure testing
6. Review the production plan artifact before merging

### Continuous Deployment (CD)

**Trigger**: Merges to `main` branch

**What it does:**
1. Automatically deploys changes to the **production environment**
2. Runs `terragrunt stack generate`
3. Initializes backend
4. Applies all changes with `--non-interactive`

**Important**: The CD pipeline automatically applies to production on merge. Always review the production plan from the CI pipeline before merging.

### GitHub Secrets Required

The bootstrap process automatically creates these secrets:
- `PROJECT_ID`: Your GCP project ID
- `WIF_PROVIDER`: Workload Identity Federation provider name
- `WIF_SERVICE_ACCOUNT`: Service account email for GitHub Actions
- `DEPLOY_KEY_TG_STACK`: SSH deploy key for catalog repository access
- `DEPLOY_KEY_TG_LIVE`: SSH deploy key for live repository access

## Testing

### Infrastructure Testing with Terratest

This repository includes automated infrastructure tests using Terratest (Go testing framework).

**Test location**: `tests/staging_stack_test.go`

**What it tests:**
- Deploys the staging environment stack
- Validates infrastructure is created successfully
- Automatically cleans up resources after testing

### Running Tests Locally

```bash
go test -v ./tests/... -timeout 30m
```

### Running Tests in CI

Add the `run-terratest` label to your pull request. The CI will:
1. Deploy infrastructure to staging
2. Run validation tests
3. Destroy all resources
4. Report results in the PR

**Note**: Tests deploy real GCP resources and may incur costs. They clean up automatically, but monitor your GCP projects to ensure proper cleanup.

### Writing Custom Tests

See the example in `tests/staging_stack_test.go`. Key patterns:
- Use `t.Cleanup()` to ensure resources are destroyed
- Test against non-production environments
- Set appropriate timeouts for long-running operations

## Development Workflow

Follow this workflow when making infrastructure changes:

### 1. Create a Feature Branch
```bash
git checkout -b feature/add-cloud-sql
```

### 2. Make Changes

Update stack configurations or add new stacks:

```hcl
# live/dev/vpc_gce/terragrunt.stack.hcl
stack "vpc_gce" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-gcp//stacks/vpc_gce?ref=v0.0.2"
  path   = "infrastructure"

  values = {
    # Update values as needed
    machine_type = "e2-small"  # Changed from e2-micro
  }
}
```

### 3. Test Locally (Dev Environment)

```bash
cd live/dev
terragrunt stack generate
terragrunt run --all plan
# Review the plan
terragrunt run --all apply --non-interactive
```

### 4. Promote to Staging

Once dev testing is successful, update staging:
```bash
cd live/staging
terragrunt stack generate
terragrunt run --all plan
terragrunt run --all apply --non-interactive
```

### 5. Create Pull Request

```bash
git add .
git commit -m "feat: upgrade compute instance size"
git push origin feature/add-cloud-sql
# Open PR on GitHub
```

### 6. CI Validation

The CI pipeline will:
- Validate HCL formatting
- Plan changes for all environments
- Show production plan as downloadable artifact

Add the `run-terratest` label to run full infrastructure tests.

### 7. Review Production Plan

Before merging, download and review the production plan artifact from the CI pipeline. This shows exactly what will be applied to production.

### 8. Merge and Deploy

Once approved and CI passes:
- Merge the PR
- CD pipeline automatically deploys to production
- Monitor the deployment in GitHub Actions

### 9. Verify Production

After deployment, verify resources in GCP console:
```bash
gcloud compute instances list --project=your-prod-project-id
```

## Best Practices

### Version Management
- Pin catalog versions in stack configurations
- Test new versions in dev/staging before production
- Document version changes in commit messages

### Environment Isolation
- Use separate GCP projects for each environment (recommended)
- Or use the same project with different resource naming
- Keep state buckets separate per environment

### State Management
- State is stored in GCS buckets: `{project-id}-tofu-state-{environment}`
- Buckets are created automatically with `--backend-bootstrap`
- Never commit state files to git

### Security
- Workload Identity Federation eliminates long-lived credentials
- Service account has minimal required permissions
- Review IAM roles in bootstrap configuration

### Change Management
- Always plan before apply
- Review production plans before merging
- Use `run-terratest` label for critical changes
- Keep production deployments small and incremental

## Troubleshooting

### Backend Initialization Fails
```bash
# Bootstrap the backend bucket
cd live/dev
terragrunt run --all init --backend-bootstrap --non-interactive
```

### Authentication Errors in CI
Verify GitHub secrets are set:
- `PROJECT_ID`
- `WIF_PROVIDER`
- `WIF_SERVICE_ACCOUNT`

Re-run the bootstrap process if secrets are missing.

### Plan Shows Unexpected Changes
```bash
# Regenerate stack to ensure latest configuration
cd live/dev
terragrunt stack generate
terragrunt run --all plan
```

### Deploy Key Permission Errors
Ensure deploy keys were created during bootstrap and added to both repositories (catalog and live).

## Repository Structure Reference

```
live/
   bootstrap/                              # One-time setup for GitHub Actions + GCP authentication
      enable_tg_github_actions/          # Workload Identity Federation (WIF) configuration
   dev/                                    # Development environment
      project.hcl                         # GCP project ID for dev
      region.hcl                          # GCP region for dev
      environment.hcl                     # Environment identifier
      vpc_gce/                            # Stack: VPC + Compute Engine
          terragrunt.stack.hcl            # Stack configuration referencing catalog
   staging/                                # Staging environment (mirrors dev structure)
      vpc_gce/
   prod/                                   # Production environment (mirrors dev structure)
       vpc_gce/
```

## Related Documentation

- [Catalog Repository](https://github.com/ConsciousML/terragrunt-template-catalog-gcp): Reusable IaC components
- [Bootstrap Setup](https://github.com/ConsciousML/terragrunt-template-catalog-gcp/tree/main/bootstrap/enable_tg_github_actions): Detailed GitHub Actions setup
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/): Official Terragrunt docs
- [Gruntwork Infrastructure Patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example): Reference architecture

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
