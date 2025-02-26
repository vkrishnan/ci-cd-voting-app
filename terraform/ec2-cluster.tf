# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your preferred version
    }
  }
}

provider "aws" {
  region = "ap-southeast-2" # Replace with your desired region
}

# Define variables for customization
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "ami" {
  type    = string
  default = "ami-09e143e99e8fa74f9" # Ubuntu 22.04 LTS (replace with your desired AMI)
}

variable "instance_type" {
  type    = string
  default = "t2.micro" # Or your preferred instance type
}


# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "main-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Create Route Table Association for Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Route Table for Private Subnet (No Internet Access)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-route-table"
  }
}

# Create Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone = "ap-southeast-2a"  # Replace with your desired AZ
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone = "ap-southeast-2a" # Replace with your desired AZ
  tags = {
    Name = "private-subnet"
  }
}

# Create Security Group for Public Instance (Allow SSH)
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious in production! Limit to your IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-sg"
  }
}

# Create Security Group for Private Instance (No SSH from outside)
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id
  # You can add rules here to allow communication within the VPC if needed
  tags = {
    Name = "private-sg"
  }
}


# User data for Minikube installation (Ubuntu)
locals {
  minikube_userdata = templatefile("${path.module}/minikube_install.sh", {}) # Empty context
}

# Create EC2 Instances
resource "aws_instance" "public_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name = "terraform-key" # replace with your key pair name
  user_data = local.minikube_userdata
  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name = "terraform-key-private" # replace with your key pair name
  user_data = local.minikube_userdata
  tags = {
    Name = "private-instance"
  }
}

# Output the public instance's public IP
output "public_instance_ip" {
  value = aws_instance.public_instance.public_ip
}