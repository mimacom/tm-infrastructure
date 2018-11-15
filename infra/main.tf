terraform {
  backend "s3" {
    encrypt                 = false
    bucket                  = "mimacom-tm-terraform-state"
    dynamodb_table          = "terraform-state-lock"
    region                  = "eu-central-1"
    key                     = "infra"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "mimacom"
  }
}

provider "aws" {
  region                  = "${local.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "mimacom"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.36.0"

  name = "${local.app_name}-${terraform.workspace}"
  cidr = "${var.cidr}"

  azs              = "${var.azs}"
  public_subnets   = "${var.public_subnets}"
  private_subnets  = "${var.private_subnets}"
  database_subnets = "${var.database_subnets}"

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  database_subnet_tags = {
    Tier = "db"
  }

  vpc_tags = {
    Name = "${local.app_name}-${terraform.workspace}"
  }

  tags = {
    Application = "${local.app_name}"
    Environment = "${terraform.workspace}"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.22.0"

  identifier = "${local.app_name}-${terraform.workspace}-db"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "${local.db_name}"
  username = "${local.db_user}"
  password = "${data.aws_secretsmanager_secret_version.data.secret_string}"
  port     = "${local.db_port}"

  vpc_security_group_ids = ["${module.db_sg.this_security_group_id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = "${var.db_retention_period}"

  subnet_ids = ["${module.vpc.database_subnets}"]

  family = "mysql5.7"

  major_engine_version = "5.7"

  skip_final_snapshot = true
  apply_immediately   = "${var.db_apply_immediately}"
  deletion_protection = false
}
