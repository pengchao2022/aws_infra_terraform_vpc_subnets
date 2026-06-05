variable "vpc_name" {
  description = "The name to be assigned to the VPC and its associated resources."
  type        = string
  nullable    = false
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, prod, staging). Used for tagging."
  type        = string
  default     = "dev"
}

variable "public_subnet_count" {
  description = "The number of public subnets to create. Must be 1 or greater."
  type        = number
  default     = 2

  validation {
    condition     = var.public_subnet_count >= 1
    error_message = "The public_subnet_count must be at least 1 to ensure internet access."
  }
}

variable "private_subnet_count" {
  description = "The number of private subnets to create."
  type        = number
  default     = 2

  validation {
    condition     = var.private_subnet_count >= 0
    error_message = "The private_subnet_count cannot be negative."
  }
}