resource "aws_key_pair" "local" {
  key_name = "${local.app_name}-keypair"
  public_key = "${file("./keys/id_rsa.pub")}"
}

data "aws_secretsmanager_secret" "dbpass_secret" {
  name = "${terraform.workspace}/db/password"
}

data "aws_secretsmanager_secret_version" "data" {
  secret_id = "${data.aws_secretsmanager_secret.dbpass_secret.id}"
}
