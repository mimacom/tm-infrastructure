data "aws_secretsmanager_secret" "dbpass_secret" {
  name = "${terraform.workspace}/db/password"
}

data "aws_secretsmanager_secret_version" "data" {
  secret_id = "${data.aws_secretsmanager_secret.dbpass_secret.id}"
}
