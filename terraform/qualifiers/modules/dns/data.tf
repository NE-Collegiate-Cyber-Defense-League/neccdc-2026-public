data "aws_route53_zone" "public" {
  name         = "chefops.tech."
  private_zone = false
}
