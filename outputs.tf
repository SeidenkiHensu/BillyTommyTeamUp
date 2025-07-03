# Sets up an output so we can see the load balancer DNS name
output "load_balancer_dns" {
  description = "The DNS name of the application load balancer."
  value       = length(aws_lb.app_lb) > 0 ? aws_lb.app_lb[0].dns_name : ""
}

# Sets up an output for the CloudWatch dashboard name
output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch dashboard for EC2 monitoring."
  value       = aws_cloudwatch_dashboard.ec2_dashboard.dashboard_name
}

# Sets up an output for the CloudWatch log group name
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for EC2 logs."
  value       = aws_cloudwatch_log_group.ec2_log_group.name
}