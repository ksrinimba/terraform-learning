terraform {
  backend "s3" {
    bucket         = "state-bucket-4-terra" # Your bucket name
    key            = "global/role/terraform.tfstate"     # Path to store state
    region         = "us-east-2"                       # Your region
    encrypt        = true
    dynamodb_table = "terraform-state-locks"           # Your DynamoDB table
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

# Create an IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  lifecycle {
    prevent_destroy = true
  }
}

# Attach basic execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  lifecycle {
    prevent_destroy = true
  }
}

output "role_arn" {
  value=aws_iam_role.lambda_exec.arn
}