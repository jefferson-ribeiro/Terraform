terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws"{
  region = "us-east-1"
}

resource "aws_s3_bucket" "jeff-s3-bucket-origin" {
  bucket = "jeff-s3-bucket-origin"
  tags = {
    Name        = "jeff-s3-bucket-origin"
    Environment = "Dev"
  }
}

resource "aws_lambda_function" "lambda_handler" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "my-deployment-package.zip"
  function_name = "lambda_handler"
  role          = "arn:aws:lambda:us-east-1:215226549206:function:lambda_handler"
  handler       = "lambda_function.py"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "python3.8"
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python38:6"]
}



resource "aws_s3_bucket" "jeff-s3-bucket-destiny" {
  bucket = "jeff-s3-bucket-destiny"
  tags = {
    Name        = "jeff-s3-bucket-destiny"
    Environment = "Dev"
  }
}