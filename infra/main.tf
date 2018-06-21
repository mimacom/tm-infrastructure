provider "aws" {
  region = "${local.region}"
  shared_credentials_file = "~/.aws/credentials"
  profile = "mimacom"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket = "mimacom-tm-tfstate"
    dynamodb_table = "terraform-state-lock-dynamo"
    region = "eu-central-1"
    key = "tm/namespaced"
    shared_credentials_file = "~/.aws/credentials"
    profile = "mimacom"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.36.0"

  name = "${local.app_name}-${terraform.workspace}"
  cidr = "${var.cidr}"

  azs = "${var.azs}"
  public_subnets = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  vpc_tags = {
    Name = "${local.app_name}-${terraform.workspace}"
  }

  tags = {
    Terraform = "true"
    Application = "${local.app_name}"
    Environment = "${terraform.workspace}"
  }
}
