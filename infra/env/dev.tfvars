cidr = "10.10.16.0/20"

azs = [
  "eu-central-1a",
  "eu-central-1b"
]

private_subnets = [
  "10.10.16.0/24"
]

public_subnets = [
  "10.10.24.0/24"
]

database_subnets = [
  "10.10.28.0/24",
  "10.10.29.0/24"
]

db_retention_period = 0
db_apply_immediately = true

nomad_cluster = {
  client_instance_type = "t2.micro"
  num_servers = 1
  num_clients = 2
}