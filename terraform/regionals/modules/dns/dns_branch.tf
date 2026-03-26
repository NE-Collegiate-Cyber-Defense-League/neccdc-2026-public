resource "aws_route53_record" "branch_web_ipv6" {
  zone_id = data.aws_route53_zone.branch.zone_id
  name    = var.team_number
  type    = "AAAA"
  ttl     = "300"
  records = var.branch_pfSense_ips.ipv6
}

resource "aws_route53_record" "branch_external_wildcard_ipv6" {
  zone_id = data.aws_route53_zone.branch.zone_id
  name    = "*.${var.team_number}"
  type    = "AAAA"
  ttl     = "300"
  records = var.branch_pfSense_ips.ipv6
}

resource "aws_route53_record" "branch_teleport_wildcard_ipv6" {
  zone_id = data.aws_route53_zone.branch.zone_id
  name    = "*.teleport.${var.team_number}"
  type    = "AAAA"
  ttl     = "300"
  records = var.branch_pfSense_ips.ipv6
}
