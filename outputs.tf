output "vpc_configurations" {
  description = "A comprehensive summary of all VPC environments created"
  value = {
    for env, vpc in module.vpc : env => {
      vpc_id                  = vpc.vpc_id
      vpc_cidr                = vpc.vpc_cidr_block
      public_subnet_ids       = vpc.public_subnet_ids
      private_subnet_ids      = vpc.private_subnet_ids
      public_route_table_id   = vpc.public_route_table_id
      private_route_table_ids = vpc.private_route_table_ids
    }
  }
}


output "dev_vpc_id" {
  description = "The ID of the Development VPC"
  value       = try(module.vpc["dev"].vpc_id, null)
}

output "prod_vpc_id" {
  description = "The ID of the Production VPC"
  value       = try(module.vpc["prod"].vpc_id, null)
}