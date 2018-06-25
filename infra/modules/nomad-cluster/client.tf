# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------

module "clients" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.4.2"

  cluster_name  = "${var.cluster_name}-client"
  instance_type = "${var.client_instance_type}"

  # Give the clients a different tag so they don't try to join the server cluster
  cluster_tag_key   = "nomad-clients"
  cluster_tag_value = "${var.cluster_name}"

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.
  min_size = "${var.num_clients}"

  max_size         = "${var.num_clients}"
  desired_capacity = "${var.num_clients}"

  ami_id    = "${var.ami_id == "" ? data.aws_ami.target_ami.image_id : var.ami_id}"
  user_data = "${data.template_cloudinit_config.init_client.rendered}"

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"

  security_groups = [
    "${module.backend_sg.this_security_group_id}",
  ]

  # To make testing easier, we allow Consul and SSH requests from any IP address here but in a production
  # deployment, we strongly recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = [
    "0.0.0.0/0",
  ]

  allowed_inbound_cidr_blocks = [
    "0.0.0.0/0",
  ]

  tags = [
    {
      key                 = "Name"
      value               = "client"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "${var.app_name}"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${terraform.workspace}"
      propagate_at_launch = true
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.3.1"

  iam_role_id = "${module.clients.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "run_client" {
  template = "${file("${path.module}/tpl/user-data-client.sh.tpl")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.cluster_tag_value}"
  }
}

data "template_cloudinit_config" "init_client" {
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
    content      = "${data.template_file.run_client.rendered}"
  }
}
