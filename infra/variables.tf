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

variable "database_subnets" {
  type = "list"
}

variable "db_retention_period" {
}

variable "db_apply_immediately" {
}

variable "nomad_cluster" {
  type = "map"
}
