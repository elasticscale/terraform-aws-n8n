## Description

This sets up a N8n cluster with two Fargate Spot instances and a ALB. It is backed by an EFS file system to store the state. The total costs are around 3 USD per month (provided your ALB is in the free tier).
It does not come with SSL (optionally it can listen for SSL connections), but this would raise the cost. You can also use a service like Cloudflare to run the SSL for you.

Note: This module has been setup as a cheap and easy way to run N8n. Data is stored on a EFS volume (you must back this up yourself). We use a single instance (Fargate Spot) so it might be replaced every now and then. N8n is not ment to run stateless behind a load balancer (you will get issues with webhooks).

## About ElasticScale

ElasticScale is a Solutions Architecture as a Service focusing on start-ups and scale-ups. For a fixed monthly subscription fee, we handle all your AWS workloads. Some services include:

* Migrating **existing workloads** to AWS
* Implementing the **Zero Trust security model**
* Integrating **DevOps principles** within your organization
* Moving to **infrastructure automation** (Terraform)
* Complying with **ISO27001 regulations within AWS**

You can **pause** the subscription at any time and have **direct access** to certified AWS professionals.

Check out our <a href="https://elasticscale.cloud" target="_blank" style="color: #14dcc0; text-decoration: underline">website</a> for more information.

<img src="https://elasticscale-public.s3.eu-west-1.amazonaws.com/logo/Logo_ElasticScale_4kant-transparant.png" alt="ElasticScale logo" width="150"/>

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
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN for HTTPS support | `string` | `null` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image to use for n8n | `string` | `"n8nio/n8n:1.4.0"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired count of n8n tasks, be careful with this to make it more than 1 as it can cause issues with webhooks not registering properly | `number` | `1` | no |
| <a name="input_fargate_type"></a> [fargate\_type](#input\_fargate\_type) | Fargate type to use for n8n (either FARGATE or FARGATE\_SPOT)) | `string` | `"FARGATE_SPOT"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to add to all resources | `string` | `"n8n"` | no |
| <a name="input_url"></a> [url](#input\_url) | URL for n8n (default is LB url), needs a trailing slash if you specify it | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | Load balancer DNS name |
