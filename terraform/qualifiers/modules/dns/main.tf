resource "aws_route53_record" "web_ipv4" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ipv4]
}


resource "aws_route53_record" "external_wildcard_ipv4" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "*.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ipv4]
}


resource "aws_route53_record" "teleport_wildcard_ipv4" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "*.teleport.${var.team_number}.${data.aws_route53_zone.public.name}"
  type    = "A"
  ttl     = "300"
  records = [var.external_ipv4]
}
