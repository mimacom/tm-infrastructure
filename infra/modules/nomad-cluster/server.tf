module "servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.3.1"

  cluster_name  = "${var.cluster_name}-server"
  cluster_size  = "${var.num_servers}"
  instance_type = "t2.micro"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.cluster_tag_value}"

  ami_id    = "${var.ami_id == "" ? data.aws_ami.target_ami.image_id : var.ami_id}"
  user_data = "${data.template_cloudinit_config.init_server.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = [
    "0.0.0.0/0",
  ]

  allowed_inbound_cidr_blocks = [
    "0.0.0.0/0",
  ]

  ssh_key_name = "${var.ssh_key_name}"

  tags = [
    {
      key                 = "Name"
      value               = "server"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "${var.app_name}"
      propagate_at_launch = true
    },
    {
      propagate_at_launch = true
      key                 = "Environment"
      value               = "${terraform.workspace}"
    },
  ]
}

module "nomad_security_group_rules" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-security-group-rules?ref=v0.4.2"

  # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
  # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  security_group_id = "${module.servers.security_group_id}"

  allowed_inbound_cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH SERVER NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "run_server" {
  template = "${file("${path.module}/tpl/user-data-server.sh.tpl")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_tag_value}"
    num_servers       = "${var.num_servers}"
  }
}

data "template_cloudinit_config" "init_server" {
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

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.run_server.rendered}"
  }
}
