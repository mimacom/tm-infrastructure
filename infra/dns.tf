resource "aws_route53_record" "backend" {
  name = "backend-${terraform.workspace}"
  type = "CNAME"
  ttl = 300
  zone_id = "${data.aws_route53_zone.main.id}"
  records = [
    "${aws_alb.public.dns_name}"
  ]
}

resource "aws_route53_record" "web" {
  name = "www-${terraform.workspace}"
  type = "CNAME"
  ttl = 300
  zone_id = "${data.aws_route53_zone.main.id}"
  records = [
    "${aws_alb.public.dns_name}"
  ]
}