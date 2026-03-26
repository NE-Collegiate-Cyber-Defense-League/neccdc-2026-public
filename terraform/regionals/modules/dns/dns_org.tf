resource "aws_route53_record" "corp_web_ipv4" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = var.team_number
  type    = "A"
  ttl     = "300"
  records = [var.corp_pfSense_ips.ipv4_internal]
}

resource "aws_route53_record" "corp_web_ipv6" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = var.team_number
  type    = "AAAA"
  ttl     = "300"
  records = var.corp_pfSense_ips.ipv6
}


resource "aws_route53_record" "corp_external_wildcard_ipv4" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = "*.${var.team_number}"
  type    = "A"
  ttl     = "300"
  records = [var.corp_pfSense_ips.ipv4_internal]
}

resource "aws_route53_record" "corp_external_wildcard_ipv6" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = "*.${var.team_number}"
  type    = "AAAA"
  ttl     = "300"
  records = var.corp_pfSense_ips.ipv6
}


resource "aws_route53_record" "corp_teleport_wildcard_ipv4" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = "*.teleport.${var.team_number}"
  type    = "A"
  ttl     = "300"
  records = [var.corp_pfSense_ips.ipv4_internal]
}

resource "aws_route53_record" "corp_teleport_wildcard_ipv6" {
  zone_id = data.aws_route53_zone.corp.zone_id
  name    = "*.teleport.${var.team_number}"
  type    = "AAAA"
  ttl     = "300"
  records = var.corp_pfSense_ips.ipv6
}
