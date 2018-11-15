module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name   = "${local.app_name}-${terraform.workspace}-db"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      rule = "mysql-tcp",
      cidr_blocks = "${var.cidr}"
    }
  ]
}
