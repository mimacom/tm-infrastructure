module "prisma_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "${local.app_name}-${terraform.workspace}-prisma"
  vpc_id = "${module.vpc.vpc_id}"
}

module "db_computed_source_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "${local.app_name}-${terraform.workspace}-db"
  vpc_id = "${module.vpc.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = "${module.prisma_sg.this_security_group_id}"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}
