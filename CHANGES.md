# Changes Made to Support Existing VPC and Private Subnets

## Summary
Modified the terraform-aws-n8n module to support using existing VPC infrastructure and private subnets for ECS tasks while maintaining backward compatibility.

## Files Modified

### 1. `variables.tf`
- Added `vpc_id` variable (optional, string, default: null)
- Added `subnet_ids` variable (optional, list(string), default: [])  
- Added `public_subnet_ids` variable (optional, list(string), default: [])
- Added `use_private_subnets` variable (optional, bool, default: false)
- **NEW**: Added `alb_allowed_cidr_blocks` variable (optional, list(string), default: ["0.0.0.0/0"])

### 2. `vpc.tf`
- Added data sources for existing VPC (`aws_vpc.existing`)
- Added data sources for existing subnets (`aws_subnets.existing_private`, `aws_subnets.existing_public`)
- Modified VPC module to only create when `vpc_id` is null (using `count`)
- **UPDATED**: Modified locals to use `ecs_subnets` instead of separate private/public subnet logic
- Added conditional logic to choose private vs public subnets for ECS based on `use_private_subnets`
- Updated subnet tag filters to use `Type = "public"` and `Type = "private"`

### 3. `alb.tf`
- Updated security group to use `local.vpc_id` instead of `module.vpc.vpc_id`
- Updated ALB to use `local.public_subnets` instead of `module.vpc.public_subnets`
- Updated target group to use `local.vpc_id` instead of `module.vpc.vpc_id`
- Updated security group egress to use `local.vpc_cidr_block`
- **NEW**: Updated ALB security group ingress rules to use `var.alb_allowed_cidr_blocks` for IP filtering

### 4. `ecs.tf`
- Updated security group to use `local.vpc_id` instead of `module.vpc.vpc_id`
- **UPDATED**: Updated ECS service network configuration to use `local.ecs_subnets`
- **NEW**: Added conditional logic for `assign_public_ip` based on `use_private_subnets`
- **NEW**: Only assigns public IP when using public subnets and no custom subnet_ids

### 5. `efs.tf`
- Updated security group to use `local.vpc_id` instead of `module.vpc.vpc_id`
- Updated security group ingress to use `local.vpc_cidr_block`
- **UPDATED**: Updated EFS mount targets to use flexible subnet selection based on `use_private_subnets`

### 6. `examples/` (Updated Directory)
- Updated `existing-vpc.tf` - Shows public subnet usage (default)
- Created `existing-vpc-private-subnets.tf` - Shows private subnet usage
- **NEW**: Created `ip-filtering.tf` - Shows ALB IP filtering usage
- Kept `new-vpc.tf` - Example showing default behavior (new VPC)

### 7. `README.md`
- Updated inputs table to include new `use_private_subnets` variable
- Maintained alphabetical sorting of inputs

## Usage Options

### 1. Using Existing VPC with Private Subnets (Routes through NAT Gateway)
```hcl
module "n8n" {
  source = "path/to/module"
  
  vpc_id = "vpc-12345678"
  use_private_subnets = true
  subnet_ids = ["subnet-private1", "subnet-private2"]
  public_subnet_ids = ["subnet-public1", "subnet-public2"]
}
```

### 2. Using Existing VPC with Public Subnets
```hcl
module "n8n" {
  source = "path/to/module"
  
  vpc_id = "vpc-12345678"
  use_private_subnets = false  # default
  subnet_ids = ["subnet-public1", "subnet-public2"]
  public_subnet_ids = ["subnet-public1", "subnet-public2"]
}
```

### 3. Creating New VPC (Default)
```hcl
module "n8n" {
  source = "path/to/module"
  
  # No VPC parameters needed - will create new VPC
  # use_private_subnets = false (default)
}
```

### 4. Using Existing VPC with IP Filtering (Enhanced Security)
```hcl
module "n8n" {
  source = "path/to/module"
  
  vpc_id = "vpc-12345678"
  use_private_subnets = true
  
  # Restrict access to specific IP ranges
  alb_allowed_cidr_blocks = [
    "203.0.113.0/24",    # Office network
    "198.51.100.0/24",   # VPN network
    "192.0.2.100/32"     # Specific admin IP
  ]
}
```

## Key Features

### Private Subnet Support
- **NAT Gateway Compatible**: When `use_private_subnets = true`, ECS tasks route internet traffic through NAT Gateway
- **Security Enhanced**: ECS tasks have no direct internet access, only through NAT
- **Cost Consideration**: Requires existing NAT Gateway infrastructure (additional AWS costs)

### Subnet Selection Logic
- **Custom Subnets**: If `subnet_ids` provided, uses those regardless of `use_private_subnets`
- **Auto-Discovery**: If no `subnet_ids`, chooses private or public based on `use_private_subnets`
- **Fallback**: Falls back to VPC module subnets when using new VPC

### Public IP Assignment
- **Private Subnets**: `assign_public_ip = false` (routes through NAT)
- **Public Subnets**: `assign_public_ip = true` (direct internet access)
- **Custom Subnets**: Assumes no public IP needed when custom subnets provided

## Backward Compatibility
All changes maintain full backward compatibility. Existing configurations will continue to work without modification.

## Requirements for Private Subnets
When using `use_private_subnets = true`, ensure your VPC has:
1. **NAT Gateway or NAT Instance** in public subnets
2. **Route tables** configured to route 0.0.0.0/0 through NAT
3. **Proper subnet tags**: `Type = "private"` for private subnets, `Type = "public"` for public subnets
