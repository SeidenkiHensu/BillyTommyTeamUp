# Setting up an output so we can see the load balancer DNS name
output "load_balancer_dns" {
  description = "The DNS name of the application load balancer."
  value       = aws_lb.app_lb.dns_name
}

# Changed the value output to display the IP addresses
output "blue_instance_public_ip" {
  description = "Public IP of the blue environment EC2 instance."
  value       = [for instance in aws_instance.blue : instance.public_ip]
}

# Changed the value output to display the IP addresses
output "green_instance_public_ip" {
  description = "Public IP of the green environment EC2 instance."
  value       = [for instance in aws_instance.green : instance.public_ip]
}

output "cloudwatch_dashboard_name" {
  description = "The name of the CloudWatch dashboard for EC2 monitoring."
  value       = aws_cloudwatch_dashboard.ec2_dashboard.dashboard_name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for EC2 logs."
  value       = aws_cloudwatch_log_group.ec2_log_group.name
}