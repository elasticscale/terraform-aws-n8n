data "aws_availability_zones" "available" {}

# Data sources for existing VPC (when vpc_id is provided)
data "aws_vpc" "existing" {
  count = var.vpc_id != null ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "existing_private" {
  count = var.vpc_id != null && length(var.subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Type = "private"
  }
}

data "aws_subnets" "existing_public" {
  count = var.vpc_id != null && length(var.public_subnet_ids) == 0 ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {
    Type = "public"
  }
}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  # VPC configuration
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  vpc_cidr_block = var.vpc_id != null ? data.aws_vpc.existing[0].cidr_block : module.vpc[0].vpc_cidr_block
  
  # Subnet configuration for ECS tasks
  ecs_subnets = length(var.subnet_ids) > 0 ? var.subnet_ids : (
    var.use_private_subnets ? (
      var.vpc_id != null ? data.aws_subnets.existing_private[0].ids : module.vpc[0].private_subnets
    ) : (
      var.vpc_id != null ? data.aws_subnets.existing_public[0].ids : module.vpc[0].public_subnets
    )
  )
  
  # Public subnets for ALB (always public)
  public_subnets = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : (
    var.vpc_id != null ? data.aws_subnets.existing_public[0].ids : module.vpc[0].public_subnets
  )
}

module "vpc" {
  count              = var.vpc_id == null ? 1 : 0
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