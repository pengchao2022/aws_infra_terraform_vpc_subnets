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