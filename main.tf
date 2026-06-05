terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region 
}
module "vpc" {
  source   = "./modules/vpc"
  
  # 遍历我们在 variables.tf 中定义的 vpc_configs map
  for_each = var.vpc_configs

  # 将 map 中的 key (dev, prod) 作为环境名称
  vpc_name             = "${each.key}-vpc"
  environment          = each.key
  
  # 从 map 的 value 中获取配置参数
  vpc_cidr             = each.value.cidr
  public_subnet_count  = each.value.public_subnet_count
  private_subnet_count = each.value.private_subnet_count
  enable_nat_gateway   = each.value.enable_nat_gateway
}