module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name = "${local.app_name}-${terraform.workspace}-ingress"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      rule = "https-443-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      description = "Fabio LB",
      from_port = 9999,
      to_port = 9999,
      protocol = "tcp",
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    }
  ]
}

resource "aws_alb" "public" {

  name = "${local.app_name}-${terraform.workspace}-public"
  internal = false

  security_groups = [
    "${module.public_sg.this_security_group_id}"
  ]

  subnets = [
    "${module.vpc.public_subnets}"
  ]
}

resource "aws_alb_target_group" "public" {

  name = "${local.app_name}-${terraform.workspace}-public"
  vpc_id = "${module.vpc.vpc_id}"

  port = 9999
  protocol = "HTTP"

  stickiness = []
}

resource "aws_alb_listener" "public" {

  load_balancer_arn = "${aws_alb.public.id}"
  port = 443
  protocol = "HTTPS"

  certificate_arn = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.public.id}"
    type = "forward"
  }
}
