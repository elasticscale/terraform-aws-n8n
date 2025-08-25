# Example: Using existing VPC with private subnets for ECS tasks

module "n8n" {
  source = "../"

  prefix = "my-n8n"
  
  # Use existing VPC
  vpc_id = "vpc-12345678"
  
  # Use private subnets for ECS tasks (requires NAT Gateway)
  use_private_subnets = true
  
  # Optionally specify specific private subnets for ECS tasks
  subnet_ids = [
    "subnet-private1",
    "subnet-private2"
  ]
  
  # Specify public subnets for ALB
  public_subnet_ids = [
    "subnet-public1", 
    "subnet-public2"
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
