cidr = "10.10.0.0/20"

azs = [
  "eu-central-1a",
  "eu-central-1b",
  "eu-central-1c"
]

private_subnets = [
  "10.10.0.0/24",
  "10.10.1.0/24",
  "10.10.2.0/24"
]

public_subnets = [
  "10.10.8.0/24",
  "10.10.9.0/24",
  "10.10.10.0/24"
]

database_subnets = [
  "10.10.13.0/24",
  "10.10.14.0/24",
  "10.10.15.0/24"
]

db_retention_period = 0
db_apply_immediately = true
