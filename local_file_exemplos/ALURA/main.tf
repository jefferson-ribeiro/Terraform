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

resource "aws_instance" "dev" {
    count = 3
    ami = "ami-08d4ac5b634553e16"
    instance_type = "t2.micro"
    key_name = "terraform-aws"
    tags = {
        Name = "dev${count.index}"
        #vpc_id = "vpc-00713ae4467efb9dd"
        #subnet_id = "subnet-0a7fea7265c14056e"
  }
}