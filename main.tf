terraform {
  required_version = ">= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Sets up a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Sets up an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Sets up a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Setting up a Public Route Table Association for Subnet A
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

# Setting up a Public Route Table Association for Subnet B
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Setting up Subnets for Blue Stack
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Setting up Subnets for Green Stack
resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Creating a Security Group for the EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name        = "Angel Grove"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  # Allows HTTP traffic from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows SSH traffic from the internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For this demo, I'm creating 3 instances for each stack, which goes against the free tier outside of this demo if using for long periods of time.
resource "aws_instance" "blue" {
  count                  = var.create_ec2_instances ? 3 : 0
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

# Adding tags to help during audit purposes like cost awareness
  tags = {
    Name              = "Billy-${count.index + 1}"
    Env               = "blue"
    EnvironmentStatus = var.active_env == "blue" ? "live" : "standby"
    InstanceNum       = "${count.index + 1}"
    Project           = "BillyTommyTeamUp"
  }
}

resource "aws_instance" "green" {
  count                  = var.create_ec2_instances ? 3 : 0
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name              = "Tommy-${count.index + 1}"
    Env               = "green"
    EnvironmentStatus = var.active_env == "green" ? "live" : "standby"
    InstanceNum       = "${count.index + 1}"
    Project           = "BillyTommyTeamUp"
  }
}

# Creating the Application Load Balancer
resource "aws_lb" "app_lb" {
#  count              = var.create_alb ? 1 : 0
  count              = var.manage_alb ? 1 : 0
  name               = "command-center"
#  name               = "command-center-${var.active_env}-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_groups    = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "Command Center"
    Environment = var.active_env
    Project     = "BillyTommyTeamUp"
    ActiveStack = var.active_env
  }
}

# This is for if the ALB is already created
data "aws_lb" "existing_app_lb" {
  count = var.manage_alb ? 0 : 1
  name  = "command-center"
}

locals {
  alb_arn = var.manage_alb ? aws_lb.app_lb[0].arn : data.aws_lb.existing_app_lb[0].arn

  blue_tg_arn  = var.manage_alb ? aws_lb_target_group.blue_tg[0].arn : data.aws_lb_target_group.blue_tg[0].arn
  green_tg_arn = var.manage_alb ? aws_lb_target_group.green_tg[0].arn : data.aws_lb_target_group.green_tg[0].arn

  active_tg_arn = var.active_env == "blue" ? local.blue_tg_arn : local.green_tg_arn
}

# Setting up a random ID for the Load Balancer so that they have unique names
/*resource "random_id" "suffix" {
  byte_length = 4
}*/

# Creating the target groups for the Application Load Balancer
resource "aws_lb_target_group" "blue_tg" {
  count    = var.manage_alb ? 1 : 0
  name     = "blue-morpher"
#  name     = "blue-morpher-${random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

data "aws_lb_target_group" "blue_tg" {
  count = var.manage_alb ? 0 : 1
  name  = "blue-morpher"
#  vpc_id = aws_vpc.main.id
}

resource "aws_lb_target_group" "green_tg" {
  count    = var.manage_alb ? 1 : 0
  name     = "green-morpher"
#  name     = "green-morpher-${random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

data "aws_lb_target_group" "green_tg" {
  count = var.manage_alb ? 0 : 1
  name  = "green-morpher"
#  vpc_id = aws_vpc.main.id
}

# Setting up a Listener for the Load Balancer
resource "aws_lb_listener" "http" {
  count             = var.manage_alb ? 1 : 0
  load_balancer_arn = local.alb_arn
  #load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # This sets the default stack to be looked at
  default_action {
    type             = "forward"
    target_group_arn = local.active_tg_arn
    #target_group_arn = var.active_env == "blue" ? aws_lb_target_group.blue_tg.arn : aws_lb_target_group.green_tg.arn
  }

# This is optional but makes sure the listener doesn't forward to a group before it's ready
  depends_on = [
    aws_lb_target_group.blue_tg,
    aws_lb_target_group.green_tg
  ]
}

data "aws_lb_listener" "http" {
  count             = var.manage_alb ? 0 : 1
  load_balancer_arn = local.alb_arn
  port              = 80
#  protocol          = "HTTP"
}

# Sets up a Target Group Attachment for the Load Balancer to the Blue Instances
resource "aws_lb_target_group_attachment" "blue_attach" {
  count            = var.create_ec2_instances ? 3 : 0
  target_group_arn = var.manage_alb ? aws_lb_target_group.blue_tg[0].arn : data.aws_lb_target_group.blue_tg[0].arn
  #target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

# Setting up a Target Group Attachment for the Load Balancer to the Green Instances
resource "aws_lb_target_group_attachment" "green_attach" {
  count            = var.create_ec2_instances ? 3 : 0
  target_group_arn = var.manage_alb ? aws_lb_target_group.green_tg[0].arn : data.aws_lb_target_group.green_tg[0].arn
  #target_group_arn = aws_lb_target_group.green_tg.arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}

# Setting up a CloudWatch Log Group for EC2 Instance Logs
resource "aws_cloudwatch_log_group" "ec2_log_group" {
  count            = var.create_ec2_instances ? 1 : 0
  name             = "ec2/instance/logs-${var.active_env}"
#  name             = "/ec2/instance/logs-${random_id.suffix.hex}"
  retention_in_days = 14
}

# Setting up a CloudWatch Dashboard for EC2 Instance Monitoring. Only setting up CPU usage for the demo
resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  count          = var.create_ec2_instances ? 1 : 0
  dashboard_name = "power-ranger-morphing-grid"
  dashboard_body = jsonencode({
    widgets = [
      {
        type       = "metric",
        x          = 0,
        y          = 0,
        width      = 24,
        height     = 6,
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.blue[0].id}" ],
            [ ".", "CPUUtilization", "InstanceId", "${aws_instance.blue[1].id}" ],
            [ ".", "CPUUtilization", "InstanceId", "${aws_instance.blue[2].id}" ],
            [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.green[0].id}" ],
            [ ".", "CPUUtilization", "InstanceId", "${aws_instance.green[1].id}" ],
            [ ".", "CPUUtilization", "InstanceId", "${aws_instance.green[2].id}" ],
          ],
          period = 300,
          stat   = "Average",
          region = var.region,
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}

# Setting up a CloudWatch Log Stream for EC2 Instance Logs
resource "aws_cloudwatch_log_stream" "ec2_log_stream" {
  count          = var.create_ec2_instances ? 1 : 0 
  name           = "ec2-instance-stream"
  log_group_name = aws_cloudwatch_log_group.ec2_log_group[0].name
}

# Data sources to find existing EC2 instances
data "aws_instances" "blue_instances" {
  count = var.create_ec2_instances ? 0 : 1
  filter {
    name   = "tag:Name"
    values = ["Billy-*"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }
}

data "aws_instances" "green_instances" {
  count = var.create_ec2_instances ? 0 : 1
  filter {
    name   = "tag:Name"
    values = ["Tommy-*"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped"]
  }
}

# Resource to manage tags for existing blue instances
resource "aws_ec2_tag" "blue_instance_tags" {
  count     = var.create_ec2_instances ? 0 : length(data.aws_instances.blue_instances[0].ids)
  resource_id = data.aws_instances.blue_instances[0].ids[count.index]
  key        = "EnvironmentStatus"
  value      = var.active_env == "blue" ? "live" : "standby"
}

# Resource to manage tags for existing green instances
resource "aws_ec2_tag" "green_instance_tags" {
  count     = var.create_ec2_instances ? 0 : length(data.aws_instances.green_instances[0].ids)
  resource_id = data.aws_instances.green_instances[0].ids[count.index]
  key        = "EnvironmentStatus"
  value      = var.active_env == "green" ? "live" : "standby"
}