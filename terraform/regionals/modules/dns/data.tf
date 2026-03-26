data "aws_route53_zone" "corp" {
  name         = "chefops.tech."
  private_zone = false
}

data "aws_route53_zone" "branch" {
  name         = "oceancrests.kitchen."
  private_zone = false
}
