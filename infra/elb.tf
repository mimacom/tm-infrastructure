// stable load balancer
resource "aws_elb" "backend" {
  name     = "backend"
  internal = false

  security_groups = [
    "${module.elb_sg.this_security_group_id}",
  ]

  subnets = [
    "${module.vpc.public_subnets}",
  ]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:9999"
    interval            = 5
  }

  // Fabio LB
  listener {
    lb_port           = 443
    lb_protocol       = "TCP"
    instance_port     = 9999
    instance_protocol = "TCP"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "TCP"
    instance_port     = 9999
    instance_protocol = "TCP"
  }

  tags = {
    Name        = "backend"
    Application = "${local.app_name}"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${module.nomad.autoscaling_group_name}"
  elb                    = "${aws_elb.backend.id}"
}

module "elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "elb"
  vpc_id = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = [
    "0.0.0.0/0",
  ]

  ingress_rules = [
    "http-80-tcp",
    "https-443-tcp",
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
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
