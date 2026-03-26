locals {
  # Starting index 1 = team 0
  teams = 18
}

module "certificates" {
  source = "../../modules/certificates"

  for_each = { for i in range(local.teams) : i => tostring(i) }

  domain_name = "chefops.tech"
  output_dir  = "../../../../documents/blue_team/qualifiers/"
  team_number = each.key
}
