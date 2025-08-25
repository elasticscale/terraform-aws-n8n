# Example: Using existing VPC with public subnets for ECS tasks (default)

module "n8n" {
  source = "../"

  prefix = "my-n8n"
  
  # Use existing VPC
  vpc_id = "vpc-12345678"
  
  # Use public subnets for ECS tasks (default behavior)
  use_private_subnets = false
  
  # Specify specific subnets for ECS tasks (public subnets in this case)
  subnet_ids = [
    "subnet-12345678",
    "subnet-87654321"
  ]
  
  # Specify public subnets for ALB
  public_subnet_ids = [
    "subnet-abcdef12",
    "subnet-fedcba21"
  ]
  
  # Optional: SSL certificate for HTTPS
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  
  # Optional: Custom domain URL
  # url = "https://n8n.example.com/"
  
  tags = {
    Environment = "production"
    Project     = "automation"
  }
}

output "n8n_url" {
  value = module.n8n.lb_dns_name
}
