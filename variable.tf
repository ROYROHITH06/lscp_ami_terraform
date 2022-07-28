variable "ami" {
  default = "ami-052efd3df9dad4825"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "subnet02_cidr" {
  default = "10.180.1.0/24"
}

variable "key_name" {
  description = "key name for the instance"
  default = "newpemkey"
}

variable "volume_size" {
  default = "30"
}
