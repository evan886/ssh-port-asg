terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "lab" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ssh-port-lab-vpc"
  }
}

# --------------------------------------------------
# Public Subnet
# --------------------------------------------------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ssh-port-lab-public"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "ssh-port-lab-igw"
  }
}

# --------------------------------------------------
# Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "ssh-port-lab-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# Security Group
# --------------------------------------------------

resource "aws_security_group" "ssh" {
  name        = "ssh-port-lab-sg"
  description = "Allow SSH for SSH port migration lab"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-port-lab-sg"
  }
}

# --------------------------------------------------
# EC2 Key Pair
# --------------------------------------------------

resource "aws_key_pair" "lab" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# --------------------------------------------------
# Amazon Linux 2023 AMI
# --------------------------------------------------

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# --------------------------------------------------
# Launch Template
# --------------------------------------------------

resource "aws_launch_template" "lab" {
  name_prefix = "ssh-port-lab-"

  image_id = data.aws_ssm_parameter.al2023.value

  instance_type = "t3.micro"

  key_name = aws_key_pair.lab.key_name

  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ssh-port-lab-ec2"
    }
  }
}

# --------------------------------------------------
# Auto Scaling Group
# --------------------------------------------------

resource "aws_autoscaling_group" "lab" {
  name = "ssh-port-lab-asg"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  vpc_zone_identifier = [
    aws_subnet.public.id
  ]

  launch_template {
    id      = aws_launch_template.lab.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "ssh-port-lab-asg-instance"
    propagate_at_launch = true
  }
}