output "load_balancer_dns" {
  description = "The DNS name of the application load balancer."
  value       = aws_lb.app_lb.dns_name
}

output "blue_instance_public_ip" {
  description = "Public IP of the blue environment EC2 instance."
  value       = aws_instance.blue.public_ip
}

output "green_instance_public_ip" {
  description = "Public IP of the green environment EC2 instance."
  value       = aws_instance.green.public_ip
}