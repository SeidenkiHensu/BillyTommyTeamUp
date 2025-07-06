# Sets up an output so we can see the load balancer DNS name
output "load_balancer_dns" {
  description = "The DNS name of the application load balancer."
  value       = var.manage_alb ? aws_lb.app_lb[0].dns_name : data.aws_lb.existing_app_lb[0].dns_name
  #value       = aws_lb.app_lb.dns_name
#  value       = var.create_alb ? aws_lb.app_lb.dns_name : ""
}

# Sets up an output for the CloudWatch dashboard name
output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch dashboard for EC2 monitoring."
  value       = var.create_ec2_instances ? aws_cloudwatch_dashboard.ec2_dashboard[0].dashboard_name : ""
}

# Sets up an output for the CloudWatch log group name
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for EC2 logs."
  value       = var.create_ec2_instances ? "/ec2/instance/logs-${var.active_env}" : ""
  #value       = var.create_ec2_instances ? aws_cloudwatch_log_group.ec2_log_group[0].name : ""
}

# Sets up an output for the active stack
output "active_stack" {
  description = "The currently active stack (blue or green)"
  value       = var.active_env
}