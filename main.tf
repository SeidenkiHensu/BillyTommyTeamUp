terraform {
  required_version = ">= 1.12.2"
}

provider "aws" {
  region = var.region
}

# Setting up a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Setting up an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Setting up a Public Route Table
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

# Setting up a Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name        = "Angel Grove"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH traffic from the internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# For this demo, I'm using 3 instances each, which goes against free tier outside of this demo
# Normally you'll use the count variable instead of setting a static number
resource "aws_instance" "blue" {
  count         = 3
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

# Adding tags to help during audit purposes like cost awareness
  tags = {
    Name        = "Billy-${count.index + 1}"
    Env         = "blue"
    InstanceNum = "${count.index + 1}"
    Project     = "BillyTommyTeamUp"
  }
}

resource "aws_instance" "green" {
  count         = 3
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_b.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

# Adding tags to help during audit purposes like cost awareness
  tags = {
    Name        = "Tommy-${count.index + 1}"
    Env         = "green"
    InstanceNum = "${count.index + 1}"
    Project     = "BillyTommyTeamUp"
  }
}

# Setting up an Application Load Balancer
resource "aws_lb" "app_lb" {
  count              = var.create_alb ? 1 : 0
  name               = "command-center"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  security_groups    = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "Command Center"
    Environment = var.active_env
    Project     = "BillyTommyTeamUp"
  }
}

# Setting up a random ID for the Load Balancer so that they have unique names
resource "random_id" "suffix" {
  byte_length = 4
}

# Setting up a target group for the Application Load Balancer
resource "aws_lb_target_group" "blue_tg" {
  name     = "blue-tg-${random_id.suffix.hex}"
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

resource "aws_lb_target_group" "green_tg" {
  name     = "green-tg-${random_id.suffix.hex}"
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

# Setting up a Listener for the Load Balancer
resource "aws_lb_listener" "http" {
  count             = var.create_alb ? 1 : 0
#  load_balancer_arn = aws_lb.app_lb.arn
  load_balancer_arn = aws_lb.app_lb[0].arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = var.active_env == "blue" ? aws_lb_target_group.blue_tg.arn : aws_lb_target_group.green_tg.arn
  }

# This is optional but makes sure the listener doesn't forward to a group before it's ready
  depends_on = [
    aws_lb_target_group.blue_tg,
    aws_lb_target_group.green_tg
  ]
}

# Setting up a Target Group Attachment for the Load Balancer to the Blue Instances
resource "aws_lb_target_group_attachment" "blue_attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

# Setting up a Target Group Attachment for the Load Balancer to the Green Instances
resource "aws_lb_target_group_attachment" "green_attach" {
  count            = 3
  target_group_arn = aws_lb_target_group.green_tg.arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}

resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name = "/ec2/instance/logs-${random_id.suffix.hex}"
  retention_in_days = 14
}

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "ec2-monitoring-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 24,
        height = 6,
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

resource "aws_cloudwatch_log_stream" "ec2_log_stream" {
  name           = "ec2-instance-stream"
  log_group_name = aws_cloudwatch_log_group.ec2_log_group.name
}