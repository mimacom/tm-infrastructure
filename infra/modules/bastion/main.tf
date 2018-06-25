data "aws_ami" "target_ami" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "virtualization-type"

    values = [
      "hvm",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/tpl/init.yml.tpl")}"
}

data "template_cloudinit_config" "cloud_init" {
  base64_encode = true
  gzip          = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.init.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content      = "${var.cloud_init_users_fragment}"
  }
}

resource "aws_instance" "default" {
  ami           = "${data.aws_ami.target_ami.id}"
  instance_type = "t2.micro"

  user_data = "${data.template_cloudinit_config.cloud_init.rendered}"

  vpc_security_group_ids = [
    "${module.bastion_sg.this_security_group_id}",
  ]

  associate_public_ip_address = "true"

  subnet_id = "${var.subnet_id}"

  tags = {
    Name        = "bastion-host"
    Application = "${var.app_name}"
    Environment = "${terraform.workspace}"
  }
}

module "bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name   = "bastion"
  vpc_id = "${var.vpc_id}"

  ingress_cidr_blocks = [
    "0.0.0.0/0",
  ]

  ingress_rules = [
    "ssh-tcp",
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
