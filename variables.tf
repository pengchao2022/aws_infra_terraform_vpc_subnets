variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_configs" {
  description = "Configuration map for all VPC environments"
  type = map(object({
    cidr                 = string
    public_subnet_count  = number
    private_subnet_count = number
  }))
}