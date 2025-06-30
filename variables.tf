variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID for EC2 instances (use a free-tier eligible AMI)."
  type        = string
}

variable "active_env" {
  description = "Which environment is live: blue or green."
  type        = string
  default     = "blue"
}

variable "user_name" {
  description = "The name of the IAM user to create."
  type        = string
}
