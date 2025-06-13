
terraform {
  backend "s3" {
    bucket         = "state-bucket-4-terra" # Your bucket name
    key            = "global/s3/terraform.tfstate"     # Path to store state
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
}

# Associate the route table with the subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
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
}

# Create the EC2 instance
resource "aws_instance" "srini1" {
  ami           = "ami-06971c49acd687c30" # Amazon Linux 2 AMI (us-east-1) - Change as needed
  instance_type = "t2.micro"             # Free tier eligible instance type
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # SSH key configuration (replace with your key name)
  key_name = "srini-ssh" # Change to your key pair name
  associate_public_ip_address = true

  user_data = file("install_apache.sh")
  
  tags = {
    Name = "srini-instance"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.srini1.public_ip
  description = "The public IP address of the EC2 instance"
}
