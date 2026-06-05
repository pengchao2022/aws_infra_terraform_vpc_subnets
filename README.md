# Terraform AWS VPC Module

This repository uses Terraform to deploy a complete AWS VPC infrastructure. When changes are merged to the `main` branch, GitHub Actions automatically deploys the infrastructure. You can modify terraform.tfvars file to destroy or remove the infrastructure VPCs.

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
## Difference between Map and List in Terraform both use for_each

- List (列表)

  - list 是一个有序的元素集合。元素在列表中通过索引 (index) 访问，从 0 开始
  - 有序、通过数字下标访问
  - 当你有一组同质化的资源，且顺序很重要（例如可用区列表，或者一组按顺序创建的子网）
  - 使用中括号 []

- example for list
```shell
# 定义一个 list
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# 访问方式：使用下标 (从0开始)
# var.availability_zones[0]  -> "us-east-1a"

```

- Map (映射 或 字典)

  - map 是一个键值对 (key-value) 的集合。元素通过自定义的键 (key) 访问，而不是通过顺序
  - 无序、通过唯一的字符串 key 查找值
  - 当你需要通过名称、ID 或环境标识来检索数据时（例如你的 vpc_configs，通过 dev 或 prod 查找配置）
  - 使用花括号 {}

- example for Map
```shell
# 定义一个 map
variable "environment_configs" {
  type = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.medium"
  }
}

# 访问方式：使用 key
# var.environment_configs["dev"]  -> "t3.micro"

```
## 详细对比

| 特性         | List (列表)                     | Map (映射)                     |
| :----------- | :------------------------------- | :----------------------------- |
| **访问方式** | `var.name[0]` (索引)             | `var.name["key"]` (键)         |
| **顺序**     | 有序                             | 无序                           |
| **用途**     | 处理序列、轮询、循环             | 查找、分类、环境标识           |
| **存储数据** | 多个相同性质的项目               | 将属性与标识绑定               |


