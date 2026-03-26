locals {
  # Starting index 1 = team 0
  teams = 11
}

module "chefops" {
  source = "../../modules/certificates"

  for_each = { for i in range(local.teams) : i => tostring(i) }

  domain_name = "chefops.tech"
  output_dir  = "../../../../documents/blue_team/regionals/chefops"
  team_number = each.key
}

module "ock" {
  source = "../../modules/certificates"

  for_each = { for i in range(local.teams) : i => tostring(i) }

  domain_name = "oceancrests.kitchen"
  output_dir  = "../../../../documents/blue_team/regionals/ock"
  team_number = each.key
}
