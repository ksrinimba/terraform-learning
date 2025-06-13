
terraform {
  backend "s3" {
    bucket         = "state-bucket-4-terra" # Your bucket name
    key            = "global/vpc/terraform.tfstate"     # Path to store state
    region         = "us-east-2"                       # Your region
    encrypt        = true
    dynamodb_table = "terraform-state-locks"           # Your DynamoDB table
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

# Create a VPC (optional but recommended for network isolation)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  # availability_zone = "us-east-2a" # Change to your preferred AZ
  tags = {
    Name = "main-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "srini-route-table"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
  lifecycle {
    prevent_destroy = true
  }
}

# Create a security group with SSH access
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

  ingress {
    description = "http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "subnet_id" {
  value=aws_subnet.main.id
}

output "vpc_security_group_id" {
  value=aws_security_group.allow_ssh.id
}