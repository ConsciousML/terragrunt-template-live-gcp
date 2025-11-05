# Continuous Integration and Deployment (CI/CD)

## Overview

The [CI](../.github/workflows/ci.yaml) and [CD](../.github/workflows/cd.yaml) workflows automate infrastructure validation, testing, and deployment on every pull request and merge.

They ensure that:
- Infrastructure changes are validated before reaching production
- All environments (dev, staging, prod) are tested
- Production deployments are reviewed
- Infrastructure can be deployed and destroyed correctly

## How It Works

### Continuous Integration (CI)

Runs automatically on every pull request to `main` and consists of four jobs:

#### 1. HCL Format Check
Validates that all Terragrunt (`.hcl`) files are properly formatted.

#### 2. Validate & Plan
Runs in parallel across **dev**, **staging**, and **prod** environments:
- Generates stack configurations
- Initializes Terragrunt with backend bootstrapping
- Validates Terraform/OpenTofu syntax
- Creates infrastructure plans showing what will change

For the **production environment**, the plan output is converted to HTML and uploaded as a downloadable artifact for review.

#### 3. Terratest
Runs infrastructure tests **only when the `run-terratest` label is added** to the PR:
- Deploys actual infrastructure to the staging environment
- Runs Go-based validation tests
- Automatically destroys all test resources

#### 4. Comment on PR
Posts a comment with:
- Link to the production plan artifact
- Commit SHA that was tested
- Warning that merging will apply changes to production

### Continuous Deployment (CD)

Runs automatically when a PR is **merged to `main`**:
- Deploys changes to the **production environment**
- Runs `terragrunt stack generate`
- Initializes backend
- Applies all changes with `--non-interactive`

**Important**: CD automatically applies to production. Always review the production plan from CI before merging.

## Setup

### Initial Setup
Follow the [bootstrap guide](https://github.com/ConsciousML/terragrunt-template-catalog-gcp/tree/main/bootstrap/enable_tg_github_actions) once to:
- Configure GitHub Actions authentication with GCP using Workload Identity Federation
- Create the service account with required IAM roles
- Set up deploy keys for private repository access
- Configure GitHub secrets

## Using the CI/CD

### Standard Pull Request Workflow

1. **Create a branch** with your infrastructure changes:
   ```bash
   git checkout -b feature/update-instance-size
   ```

2. **Make your changes** to stack configurations in `live/dev/`, `live/staging/`, or `live/prod/`

3. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "feat: increase compute instance size"
   git push origin feature/update-instance-size
   ```

4. **Open a pull request** - The CI pipeline runs automatically:
   - HCL format check validates formatting
   - Validate & Plan runs on all three environments
   - Production plan artifact is generated

5. **Review the CI results**:
   - Check that all validation passes
   - Download and review the **production plan artifact** (linked in PR comment)
   - The plan shows exactly what will be created, modified, or destroyed

6. **(Optional) Add `run-terratest` label** for critical changes:
   - Tests deploy real infrastructure to staging
   - Validates functionality end-to-end
   - Automatically cleans up resources
   - Use this before merging significant changes

7. **Review and merge** once CI passes and production plan looks correct

8. **CD automatically deploys to production** after merge completes
