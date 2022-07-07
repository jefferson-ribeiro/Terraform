variable "amis" {
  type = map
  default = {
    "us-east-1" = "ami-08d4ac5b634553e16"
    "us-east-2" = "ami-02d1e544b84bf7502"
  }
}

variable "cdirs_acesso_remoto" {
  type = list
  default = [
    "177.35.164.202/32"
  ]
}

variable "key_name" {
  default = "terraform-aws"
}

