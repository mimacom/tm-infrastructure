resource "aws_route53_zone" "main" {
  name = "tm.mimacom.solutions"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "main"
    Environment = "global"
    App = "state"
  }
}