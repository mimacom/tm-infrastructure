data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "mimacom-nomad-consul-docker-amazon-linux-*",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/tpl/init.yml.tpl")}"
}

module "backend_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "backend"
  vpc_id = "${var.vpc_id}"

  ingress_cidr_blocks = [
    "0.0.0.0/0",
  ]

  ingress_rules = [
    "all-tcp",
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "${var.vpc_cidr}"
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
