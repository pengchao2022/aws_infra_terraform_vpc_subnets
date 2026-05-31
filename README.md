# Terraform AWS VPC Module

This repository uses Terraform to deploy a complete AWS VPC infrastructure. When changes are merged to the `main` branch, GitHub Actions automatically deploys the infrastructure. Resource destruction must be performed manually.

## Architecture Overview

This module creates the following AWS resources:

- **1 VPC** with customizable CIDR block (default: 10.0.0.0/16)
- **3 Public Subnets** (distributed across 3 Availability Zones)
- **3 Private Subnets** (distributed across 3 Availability Zones)
- **1 Internet Gateway (IGW)** for public internet access
- **Route Tables** and associations for public and private subnets

## Prerequisites

- AWS account with appropriate permissions
- GitHub repository configured with OIDC or AWS credentials (see [Authentication](#authentication) below)
- Terraform 1.0+ (automatically handled by GitHub Actions)

## Authentication

### Using OIDC (Recommended)

**No need to configure AWS access keys in GitHub Secrets!** This repository uses an IAM Role with GitHub OIDC authentication.

Instead of storing long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub secrets, GitHub Actions securely assumes an IAM role to access AWS resources.

### Manual Configuration (Alternative)

If not using OIDC, configure the following secrets in GitHub repository settings:

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key with VPC creation permissions |
| `AWS_SECRET_ACCESS_KEY` | Corresponding secret access key |

## GitHub Actions Workflow

### Automatic Deployment (Merge to main)

When code is merged to the `main` branch, GitHub Actions will:

1. Run `terraform plan` to show what will change
2. Run `terraform apply -auto-approve` to deploy the infrastructure

### Manual Destruction

⚠️ **Resources are NOT automatically destroyed.** To clean up resources, you must manually run the destroy workflow:

1. Go to GitHub repository → **Actions** tab
2. Select **Terraform Destroy** workflow (if configured)
3. Click **Run workflow** → **Run workflow**

Or run locally:

```bash
# Clone the repository
git clone <repository-url>
cd <repository-directory>

# Initialize Terraform
terraform init

# Destroy all resources
terraform destroy