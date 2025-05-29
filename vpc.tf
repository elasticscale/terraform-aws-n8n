data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "${var.prefix}-vpc"
  cidr               = local.vpc_cidr
  azs                = local.azs
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}