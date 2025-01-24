module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "reversed-ip-vpc"
  cidr = "117.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["117.0.1.0/24", "117.0.2.0/24", "117.0.3.0/24"]
  public_subnets  = ["117.0.101.0/24", "117.0.102.0/24", "117.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}