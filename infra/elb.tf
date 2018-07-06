// stable load balancer
data "aws_acm_certificate" "cert" {
  domain = "www.mimacom-tm.tk"
  most_recent = true
}

resource "aws_elb" "main" {
  name = "main"
  internal = false

  security_groups = [
    "${module.elb_sg.this_security_group_id}",
  ]

  subnets = [
    "${module.vpc.public_subnets}",
  ]

  idle_timeout = 3600

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "tcp:9999"
    interval = 5
  }

  // Fabio LB
  listener {
    ssl_certificate_id = "${data.aws_acm_certificate.cert.arn}"
    lb_port = 443
    lb_protocol = "https"
    instance_port = 9999
    instance_protocol = "http"
  }

  // temporary renewal
  /*
  listener {
    lb_port = 80
    lb_protocol = "TCP"
    instance_port = 9999
    instance_protocol = "TCP"
  }
  */

  tags = {
    Name = "main"
    Application = "${local.app_name}"
    Environment = "${terraform.workspace}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${module.nomad.autoscaling_group_name}"
  elb = "${aws_elb.main.id}"
}

module "elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "elb"
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
      rule = "all-tcp"
      cidr_blocks = "${var.cidr}"
    },
    {
      rule = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
