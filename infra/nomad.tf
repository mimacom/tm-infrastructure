module "nomad_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name = "${local.app_name}-${terraform.workspace}-nomad"
  vpc_id = "${module.vpc.vpc_id}"

  /*
  ingress_with_cidr_blocks = [
    {
      rule = "nomad-http-tcp",
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-tcp",
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    }
  ]


  egress_with_cidr_blocks = [
    {
      rule = "-http-tcp",
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "all-tcp",
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    }
  ]
  */


  ingress_with_cidr_blocks = [
    {
      rule = "all-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule = "all-tcp",
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


resource "aws_alb" "nomad" {
  name = "${local.app_name}-${terraform.workspace}-nomad"
  internal = false

  security_groups = [
    "${module.nomad_sg.this_security_group_id}"
  ]
  subnets = [
    "${module.vpc.public_subnets}"
  ]
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

resource "aws_alb_listener" "nomad" {
  load_balancer_arn = "${aws_alb.nomad.arn}"
  port = "4646"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nomad.arn}"
    type = "forward"
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
    "${aws_alb_target_group.public.arn}"
  ]

  server_target_groups = [
    "${aws_alb_target_group.nomad.arn}"
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
