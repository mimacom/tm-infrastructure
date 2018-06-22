data "aws_ami" "target_ami" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2"
    ]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon"
    ]
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/tpl/init.yml.tpl")}"
}

data "template_cloudinit_config" "cloud_init" {

  base64_encode = true
  gzip = true

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.init.rendered}"
  }
}

resource "aws_instance" "default" {
  ami = "${data.aws_ami.target_ami.id}"
  instance_type = "t2.micro"

  user_data = "${data.template_cloudinit_config.cloud_init.rendered}"

  vpc_security_group_ids = [
    "${var.security_group_id}"
  ]

  associate_public_ip_address = "true"

  key_name = "${var.key_name}"

  subnet_id = "${var.subnet_id}"

  tags = {
    Name = "${var.app_name}-${terraform.workspace}-bastion"
    Application = "${var.app_name}"
    Environment = "${terraform.workspace}"
  }
}