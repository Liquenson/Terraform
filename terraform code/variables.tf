variable "region" {
  description = "The AWS region to deploy into."
  default     = "us-east-1"
}

variable "ami" {
  description = "The AMI ID to use for the EC2 instance."
}

variable "instance_type" {
  description = "The type of EC2 instance."
  default     = "t2.micro"
}
