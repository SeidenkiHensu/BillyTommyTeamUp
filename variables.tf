# Setting up the default aws region
variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

# Setting up the default AMI ID
variable "ami_id" {
  description = "The AMI ID for EC2 instances. I'm using a free-tier eligible AMI."
  type        = string
}

# Sets the default on if ec2 instances need to be created. This is so I can have a list of ec2 instances that already exist in AWS
variable "create_ec2_instances" {
  description = "Whether to create EC2 instances."
  type        = bool
  default     = true
}

# Setting the Active/Live stack between blue and green. This way I'll have a default stack for the environment
variable "active_env" {
  description = "Which environment is live: blue or green."
  type        = string
  default     = "blue"
  validation {
    condition     = can(regex("^(blue|green)$", var.active_env))
    error_message = "active_env must be either 'blue' or 'green'."
  }
}

# Setting up a variable on if an ALB is already created
variable "manage_alb" {
  description = "Whether Terraform should manage (create) the ALB"
  type        = bool
  default     = true
}

# Setting up a variable for usernames. Having it set up as a list is so I can list multple users if need be
variable "user_name" {
  description = "The name of the IAM user to create."
  type        = list(string)
}

# Sets the default on on existing AWS users. This is so it knows users already exist in AWS
variable "existing_users" {
  description = "List of IAM users that already exist in AWS"
  type        = list(string)
  default     = []
}