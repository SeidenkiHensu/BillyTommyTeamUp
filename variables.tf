# Setting up a variable for the default region. I'll have a default value for the region and have it switch between different regions if need be.
variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

# Setting up a variable for the AMI ID. This is so I can have a default value for the AMI and have it switch between different AMIs
variable "ami_id" {
  description = "The AMI ID for EC2 instances (use a free-tier eligible AMI)."
  type        = string
}

# Setting an Active Environment Variable. This way I'll have a default stack for the environment and have it switch between blue and green
variable "active_env" {
  description = "Which environment is live: blue or green."
  type        = string
  default     = "blue"
}

# Setting up a variable for usernames.  Having it set up as a list is so I can have multple users
variable "user_name" {
  description = "The name of the IAM user to create."
  type        = list(string)
}
