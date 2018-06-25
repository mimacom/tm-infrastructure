output "bastion_public_ip" {
  value = "${module.bastion.public_ip}"
}

output "vpc_cidr" {
  value = "${var.cidr}"
}
