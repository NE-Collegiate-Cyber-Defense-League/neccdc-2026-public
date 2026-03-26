data "aws_route53_zone" "domain" {
  name         = "chefops.tech"
  private_zone = false
}
