/*
   This module generates a cloud init fragment that will create new users taken from the provided group
   on all the instances of the cluster
*/
data "external" "users" {
  program = [
    "bash",
    "${path.module}/script/get_users.sh",
  ]

  query {
    group_name  = "${var.iam_user_group}"
    aws_profile = "${var.aws_cli_profile}"
  }
}

locals {
  users = "${split(",",data.external.users.result.users)}"
}

data "external" "ssh_public_keys" {
  count = "${length(local.users)}"

  program = [
    "bash",
    "${path.module}/script/get_keys.sh",
  ]

  query {
    user_name   = "${local.users[count.index]}"
    aws_profile = "${var.aws_cli_profile}"
  }
}

locals {
  key_map = "${zipmap(data.external.ssh_public_keys.*.result.user_name, data.external.ssh_public_keys.*.result.ssh_public_key)}"
}

data "template_file" "users_head" {
  template = "${file("${path.module}/tpl/users_head.yml.tpl")}"
}

data "template_file" "users_body" {
  count    = "${length(local.users)}"
  template = "${file("${path.module}/tpl/user_body.yml.tpl")}"

  vars {
    user_name      = "${local.users[count.index]}"
    groups         = "${join(", ", var.join_groups)}"
    ssh_public_key = "${lookup(local.key_map, local.users[count.index])}"
  }
}

locals {
  cloud_init_users_fragment = "${data.template_file.users_head.rendered}${join("", data.template_file.users_body.*.rendered)}"
}
