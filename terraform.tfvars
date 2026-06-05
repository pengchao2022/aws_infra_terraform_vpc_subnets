# terraform.tfvars
vpc_configs = {
  dev = {
    cidr                 = "10.10.0.0/16"
    public_subnet_count  = 2
    private_subnet_count = 2
  }
  prod = {
    cidr                 = "10.20.0.0/16"
    public_subnet_count  = 3
    private_subnet_count = 3
  }
}