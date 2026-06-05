provider "aws" {
  region = var.aws_region
}

# 通过 for_each 动态循环创建 VPC 模块
# 这将根据 terraform.tfvars 中的 vpc_configs map 自动实例化对应的环境
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
}