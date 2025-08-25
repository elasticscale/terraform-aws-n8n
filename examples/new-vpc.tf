# Example: Creating new VPC with n8n module (default behavior)

module "n8n" {
  source = "../"

  prefix = "my-n8n"
  
  # VPC will be created automatically when vpc_id is not specified
  # vpc_id = null (default)
  # subnet_ids = [] (default)
  # public_subnet_ids = [] (default)
  
  # Optional: SSL certificate for HTTPS
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  
  # Optional: Custom domain URL
  # url = "https://n8n.example.com/"
  
  tags = {
    Environment = "development"
    Project     = "automation"
  }
}

output "n8n_url" {
  value = module.n8n.lb_dns_name
}
