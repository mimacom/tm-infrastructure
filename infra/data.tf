data "aws_secretsmanager_secret" "dbpass_secret" {
  name = "${terraform.workspace}/db/password"
}

data "aws_secretsmanager_secret_version" "data" {
  secret_id = "${data.aws_secretsmanager_secret.dbpass_secret.id}"
}

data "aws_route53_zone" "main" {
  name = "tm.mimacom.solutions"
}

data "aws_acm_certificate" "cert" {
  domain = "tm.mimacom.solutions"
  most_recent = true
}
