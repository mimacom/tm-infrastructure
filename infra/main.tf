provider "aws" {
  region                  = "${local.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "mimacom"
}

terraform {
  backend "s3" {
    encrypt                 = true
    bucket                  = "mimacom-tm-tfstate"
    dynamodb_table          = "terraform-state-lock-dynamo"
    region                  = "eu-central-1"
    key                     = "tm/namespaced"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "mimacom"
  }
}

module "users" {
  source = "modules/users"

  aws_cli_profile = "mimacom"
  iam_user_group  = "developers"
  join_groups     = ["users"]
}

module "bastion" {
  source = "modules/bastion"

  vpc_id    = "${module.vpc.vpc_id}"
  vpc_cidr  = "${var.cidr}"
  subnet_id = "${module.vpc.public_subnets[0]}"

  app_name                  = "${local.app_name}"
  cloud_init_users_fragment = "${module.users.cloud_init_users_fragment}"
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.19.0"

  identifier = "${local.app_name}-${terraform.workspace}-db"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "${local.db_name}"
  username = "${local.db_user}"
  password = "${data.aws_secretsmanager_secret_version.data.secret_string}"
  port     = "${local.db_port}"

  vpc_security_group_ids = ["${module.db_computed_source_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = "${var.db_retention_period}"

  subnet_ids = ["${module.vpc.database_subnets}"]

  family = "mysql5.7"

  major_engine_version = "5.7"

  skip_final_snapshot = true
  apply_immediately   = "${var.db_apply_immediately}"
}

module "nomad" {
  source = "modules/nomad-cluster"

  vpc_id               = "${module.vpc.vpc_id}"
  subnet_ids           = "${module.vpc.private_subnets}"
  vpc_cidr             = "${var.cidr}"
  cluster_name         = "${local.app_name}-${terraform.workspace}"
  client_instance_type = "${lookup(var.nomad_cluster, "client_instance_type")}"
  num_servers          = "${lookup(var.nomad_cluster, "num_servers")}"
  num_clients          = "${lookup(var.nomad_cluster, "num_clients")}"

  app_name                  = "${local.app_name}"
  cloud_init_users_fragment = "${module.users.cloud_init_users_fragment}"
}
