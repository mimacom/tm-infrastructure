variable "cidr" {
  description = "CIDR block of the VPC"
}

variable "azs" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}