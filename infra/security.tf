module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${local.app_name}-${terraform.workspace}-bastion"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = [
    "0.0.0.0/0",
  ]

  ingress_rules = [
    "ssh-tcp",
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "${var.cidr}"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "prisma_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${local.app_name}-${terraform.workspace}-prisma"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = [
    "${var.cidr}",
  ]

  ingress_rules = [
    "ssh-tcp",
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "${var.cidr}"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "db_computed_source_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "${local.app_name}-${terraform.workspace}-db"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = [
    "${var.cidr}",
  ]

  ingress_rules = [
    "mysql-tcp",
  ]
}
