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

resource "aws_s3_bucket" "jeff-s3-bucket-destiny" {
  bucket = "jeff-s3-bucket-destiny"
  tags = {
    Name        = "jeff-s3-bucket-destiny"
    Environment = "Dev"
  }
}

resource "aws_lambda_function" "lambda_handler" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "my-deployment-package.zip"
  function_name = "lambda_handler"
  role          = "arn:aws:iam::215226549206:role/service-role/lambda_handler-role-bnlhzmtl"
  handler       = "lambda_function.lambda_handler"
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime = "python3.8"
  layers = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSDataWrangler-Python38:8"]
  timeout = 12
}

resource "aws_sns_topic" "s3-event-notification-topic" {
  name = "s3-event-notification-topic"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-east-1:215226549206:s3-event-notification-topic",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:s3:::jeff-s3-bucket-origin"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.s3-event-notification-topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_handler.arn
}

resource "aws_lambda_permission" "lambda_authorizer_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "lambda_handler"
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic_subscription.user_updates_sqs_target.topic_arn
}

resource "aws_s3_bucket_notification" "s3-bucket-origin-notification" {
  bucket = aws_s3_bucket.jeff-s3-bucket-origin.id
  topic {
    topic_arn     = aws_sns_topic.s3-event-notification-topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
}


