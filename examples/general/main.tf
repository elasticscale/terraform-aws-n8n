provider "aws" {
  region = "eu-west-1"
}

module "n8n" {
  source = "../../"
}
