terraform {
  backend "s3" {
    bucket         = "state-bucket-4-terra" # Your bucket name
    key            = "global/lambda/terraform.tfstate"     # Path to store state
    region         = "us-east-2"                       # Your region
    encrypt        = true
    dynamodb_table = "terraform-state-locks"           # Your DynamoDB table
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

variable "lamda-py-file" {
  description = "Python code for the Lambda function"
  type        = string # Path to the file my_lambda.py, this name is used as module name of "handler"
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
}

# Attach basic execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create a ZIP file containing the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_file = var.lamda-py-file
}

# Create the Lambda function
resource "aws_lambda_function" "hello_world" {
  function_name    = "SriniHelloWorld"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "my_lambda.lambda_handler"
  runtime          = "python3.9" # Can also use python3.8, python3.10, or python3.11
  memory_size      = 128
  timeout          = 3

  environment {
    variables = {
      greeting = "Hello World env"
    }
  }
}

resource "aws_lambda_function_url" "test_hello" {
  function_name      = aws_lambda_function.hello_world.function_name
  authorization_type = "NONE"
}


# Output the Lambda function ARN
output "lambda_arn" {
  value = aws_lambda_function.hello_world.arn
}

# Output the Lambda function name
output "lambda_name" {
  value = aws_lambda_function.hello_world.function_name
}

# Output the Lambda function URL
output "lamda_url" {
  value = aws_lambda_function_url.test_hello.function_url
}
