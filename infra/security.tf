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
