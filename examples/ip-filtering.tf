# Example: Using IP filtering for ALB access

module "n8n" {
  source = "../"

  prefix = "secure-n8n"
  
  # Use existing VPC with private subnets for enhanced security
  vpc_id = "vpc-12345678"
  use_private_subnets = true
  subnet_ids = ["subnet-private1", "subnet-private2"]
  public_subnet_ids = ["subnet-public1", "subnet-public2"]
  
  # Restrict ALB access to specific IP ranges
  alb_allowed_cidr_blocks = [
    "203.0.113.0/24",    # Office network
    "198.51.100.0/24",   # VPN network
    "192.0.2.100/32"     # Specific admin IP
  ]
  
  # SSL certificate for HTTPS
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  url = "https://n8n.secure-company.com/"
  
  tags = {
    Environment = "production"
    Security    = "restricted"
    Project     = "automation"
  }
}

output "n8n_url" {
  value = module.n8n.lb_dns_name
  description = "N8N URL - accessible only from allowed IP ranges"
}
