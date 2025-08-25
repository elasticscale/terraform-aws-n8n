## Description

This sets up a N8n cluster with two Fargate Spot instances and a ALB. It is backed by an EFS file system to store the state. The total costs are around 3 USD per month (provided your ALB is in the free tier).
It does not come with SSL (optionally it can listen for SSL connections), but this would raise the cost. You can also use a service like Cloudflare to run the SSL for you.

Note: This module has been setup as a cheap and easy way to run N8n. Data is stored on a EFS volume (you must back this up yourself). We use a single instance (Fargate Spot) so it might be replaced every now and then. N8n is not ment to run stateless behind a load balancer (you will get issues with webhooks).

Check out or blog post about it here: [Run n8n on AWS for less than a cup of coffee per month](https://elasticscale.com/blog/run-n8n-on-aws-for-less-than-a-cup-of-coffee-per-month/)

## About ElasticScale

Discover ES Foundation, the smart digital infrastructure for SaaS companies that want to grow and thrive.

Check out our <a href="https://elasticscale.com" target="_blank" style="color: #FFB600; text-decoration: underline">website</a> for more information.

<img src="https://static.elasticscale.io/email/banner.png" alt="ElasticScale banner" width="100%"/>

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.taskdef](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_iam_role.executionrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.taskrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.n8n](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_allowed_cidr_blocks"></a> [alb\_allowed\_cidr\_blocks](#input\_alb\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the ALB (default: allows all traffic) | `list(string)` | `["0.0.0.0/0"]` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN for HTTPS support | `string` | `null` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image to use for n8n | `string` | `"n8nio/n8n:1.4.0"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired count of n8n tasks, be careful with this to make it more than 1 as it can cause issues with webhooks not registering properly | `number` | `1` | no |
| <a name="input_fargate_type"></a> [fargate\_type](#input\_fargate\_type) | Fargate type to use for n8n (either FARGATE or FARGATE\_SPOT)) | `string` | `"FARGATE_SPOT"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to all resources | `string` | `"n8n"` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet IDs for ALB (optional, uses VPC public subnets if not provided) | `list(string)` | `[]` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for HTTPS listner. | `string` | `ELBSecurityPolicy-TLS13-1-2-2021-06` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for ECS tasks (optional, uses VPC subnets if not provided) | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `null` | no |
| <a name="input_url"></a> [url](#input\_url) | URL for n8n (default is LB url), needs a trailing slash if you specify it | `string` | `null` | no |
| <a name="input_use_private_subnets"></a> [use\_private\_subnets](#input\_use\_private\_subnets) | Whether to deploy ECS tasks in private subnets (requires NAT Gateway or VPC endpoints for internet access) | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy n8n into (optional, creates new VPC if not provided) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | Load balancer DNS name |
