provider "aws" {
  region = "eu-west-1"
}

// you can also inject a SSL certificate, or just Cloudflare for free SSL
module "n8n" {
  source = "../../"
}

output "lb_dns_name" {
  value = module.n8n.lb_dns_name
}