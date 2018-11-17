module "nomad_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name = "${local.app_name}-${terraform.workspace}-nomad"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      rule = "all-tcp",
      cidr_blocks = "${module.vpc.vpc_cidr_block},46.237.207.188/32"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule = "all-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


resource "aws_alb" "management" {
  name = "${local.app_name}-${terraform.workspace}-management"
  internal = false

  security_groups = [
    "${module.nomad_sg.this_security_group_id}"
  ]

  subnets = [
    "${module.vpc.public_subnets}"
  ]
}

resource "aws_alb_listener" "management" {

  load_balancer_arn = "${aws_alb.management.arn}"
  port = 443
  protocol = "HTTPS"

  certificate_arn = "${data.aws_acm_certificate.cert.arn}"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol = "HTTPS"
      host = "nomad-${terraform.workspace}.${local.app_name}.${local.dns_zone}"
    }
  }
}

resource "aws_alb_target_group" "nomad" {

  name = "${local.app_name}-${terraform.workspace}-nomad"
  vpc_id = "${module.vpc.vpc_id}"

  port = 4646
  protocol = "HTTP"

  health_check {
    path = "/v1/status/leader"
    matcher = "200,202"
  }
}

resource "aws_alb_listener_rule" "nomad" {

  listener_arn = "${aws_alb_listener.management.arn}"

  action {
    target_group_arn = "${aws_alb_target_group.nomad.arn}"
    type = "forward"
  }

  condition {
    field  = "host-header"
    values = ["nomad-${terraform.workspace}.${local.app_name}.${local.dns_zone}"]
  }
}

resource "aws_alb_target_group" "consul" {

  name = "${local.app_name}-${terraform.workspace}-consul"
  vpc_id = "${module.vpc.vpc_id}"

  port = 8500
  protocol = "HTTP"
}

resource "aws_alb_listener_rule" "consul" {

  listener_arn = "${aws_alb_listener.management.arn}"

  action {
    target_group_arn = "${aws_alb_target_group.consul.arn}"
    type = "forward"
  }

  condition {
    field  = "host-header"
    values = ["consul-${terraform.workspace}.${local.app_name}.${local.dns_zone}"]
  }
}

resource "aws_alb_target_group" "flb_ui" {

  name = "${local.app_name}-${terraform.workspace}-flb-ui"
  vpc_id = "${module.vpc.vpc_id}"

  port = 9998
  protocol = "HTTP"
}

resource "aws_alb_listener_rule" "flb_ui" {

  listener_arn = "${aws_alb_listener.management.arn}"

  action {
    target_group_arn = "${aws_alb_target_group.flb_ui.arn}"
    type = "forward"
  }

  condition {
    field  = "host-header"
    values = ["flb-${terraform.workspace}.${local.app_name}.${local.dns_zone}"]
  }
}

resource "aws_alb_target_group" "prisma" {

  name = "${local.app_name}-${terraform.workspace}-prisma"
  vpc_id = "${module.vpc.vpc_id}"

  port = 4466
  protocol = "HTTP"
}

resource "aws_alb_listener_rule" "prisma" {

  listener_arn = "${aws_alb_listener.management.arn}"

  action {
    target_group_arn = "${aws_alb_target_group.prisma.arn}"
    type = "forward"
  }

  condition {
    field  = "host-header"
    values = ["prisma-${terraform.workspace}.${local.app_name}.${local.dns_zone}"]
  }
}

resource "aws_alb_target_group" "debug" {

  name = "${local.app_name}-${terraform.workspace}-debug"
  vpc_id = "${module.vpc.vpc_id}"

  port = 9229
  protocol = "HTTP"
}

resource "aws_alb_listener" "debug" {

  load_balancer_arn = "${aws_alb.management.arn}"
  port = 9229
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.debug.arn}"
  }
}

module "nomad" {
  source = "github.com/nicholasjackson/terraform-aws-hashicorp-suite"

  vpc_id = "${module.vpc.vpc_id}"
  key_name = ""
  namespace = "aws-${local.region}"

  instance_type = "t2.micro"

  min_servers = "1"
  max_servers = "1"
  min_agents = "1"
  max_agents = "1"

  security_group = "${module.nomad_sg.this_security_group_id}"

  subnets = [
    "${module.vpc.private_subnets}"
  ]

  client_target_groups = [
    "${aws_alb_target_group.public.arn}",
    "${aws_alb_target_group.consul.arn}",
    "${aws_alb_target_group.flb_ui.arn}",
    "${aws_alb_target_group.prisma.arn}",
    "${aws_alb_target_group.debug.arn}"
  ]

  server_target_groups = [
    "${aws_alb_target_group.nomad.arn}",
  ]

  consul_enabled = true
  consul_version = "1.4.0"
  consul_connect_enabled = "true"
  consul_join_tag_key = "autojoin"
  consul_join_tag_value = "aws-${local.region}"

  nomad_enabled = true
  nomad_version = "0.8.6"

  vault_enabled = false
  vault_version = ""
}
