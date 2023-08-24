output "lb_dns_name" {
  type = string
  description = "Load balancer DNS name"
  value = aws_lb.main.dns_name
}