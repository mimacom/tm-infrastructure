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
