variable "primary_region" {
  default = "us-east-1"
}

variable "secondary_region" {
  default = "us-west-2"
}

variable "vpc_id" {
  default = "vpc-0dc48a0e59ad268a7"
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "MyWeb"
    Environment = "Production"
  }
}