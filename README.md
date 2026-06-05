# Terraform AWS VPC Module

This repository uses Terraform to deploy a complete AWS VPC infrastructure. When changes are merged to the `main` branch, GitHub Actions automatically deploys the infrastructure. Resource destruction must be performed manually.

## Architecture Overview

This module creates the following AWS resources:

- will create VPCs for different ENV (prod , dev)
- all the VPCs will have igw
- You can decide enable NAT or not by modifing the terraform.tfvars 
- Using for_each to create VPCs in different Environment


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

then will trigger "deploy-vpc.yaml" Github action workflow to deploy AWS resources

## for_each used in main.tf

```shell
module "vpc" {
  source   = "./modules/vpc"
  
  # Iterate through the vpc_configs map we defined in variables.tf
  for_each = var.vpc_configs

  # Use the key (dev, prod) in the map as the environment name
  vpc_name             = "${each.key}-vpc"
  environment          = each.key
  
  # Retrieve configuration parameters from the value of the map
  vpc_cidr             = each.value.cidr
  public_subnet_count  = each.value.public_subnet_count
  private_subnet_count = each.value.private_subnet_count
  enable_nat_gateway   = each.value.enable_nat_gateway
}
```

## Destroy Infrastructure or Remove VPC

- You can modify terraform.tfvars file to destroy whole infrastructure or remove Prod or Dev VPCs

- Destroy ALL VPCs using an empty map

```shell
vpc_configs = {
#   dev = {
#     cidr                 = "10.10.0.0/16"
#     public_subnet_count  = 2
#     private_subnet_count = 2
#     enable_nat_gateway   = true
#   }
#   prod = {
#     cidr                 = "10.20.0.0/16"
#     public_subnet_count  = 3
#     private_subnet_count = 3
#     enable_nat_gateway   = true
#   }
}

```
- Remove DEV VPC 

```shell
vpc_configs = {
#   dev = {
#     cidr                 = "10.10.0.0/16"
#     public_subnet_count  = 2
#     private_subnet_count = 2
#     enable_nat_gateway   = true
#   }
  prod = {
    cidr                 = "10.20.0.0/16"
    public_subnet_count  = 3
    private_subnet_count = 3
    enable_nat_gateway   = true
  }
}

```

- Remove PROD VPC

```shell
vpc_configs = {
  dev = {
    cidr                 = "10.10.0.0/16"
    public_subnet_count  = 2
    private_subnet_count = 2
    enable_nat_gateway   = true
  }
#   prod = {
#     cidr                 = "10.20.0.0/16"
#     public_subnet_count  = 3
#     private_subnet_count = 3
#     enable_nat_gateway   = true
#   }
}
```



