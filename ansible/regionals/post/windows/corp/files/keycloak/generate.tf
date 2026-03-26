terraform {
  required_version = "~> 1.13.2"

  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.7.0"
    }
  }

  backend "local" {
    path = ".terraform/state"
  }
}

provider "keycloak" {
  client_id                = "admin-cli"
  username                 = "admin"
  password                 = "changeme"
  url                      = "https://[2600:1f26:1d:8a02::adf5]"
  tls_insecure_skip_verify = true
}

locals {
  base_dn    = "DC=ad,DC=chefops,DC=local"
  users_ou   = "OU=users,OU=chefops,${local.base_dn}"
  chefops_ou = "OU=chefops,${local.base_dn}"

  ldap_user_attributes = {
    Department = "department"
    Position   = "title"
  }
}

resource "keycloak_realm" "realm" {
  realm        = "chefops"
  enabled      = true
  display_name = "Chefops Realm"

  registration_allowed     = true
  reset_password_allowed   = true
  remember_me              = true
  verify_email             = false
  login_with_email_allowed = true
  ssl_required             = "none"
}

resource "keycloak_realm_events" "realm_events" {
  realm_id = keycloak_realm.realm.id

  events_enabled    = true
  events_expiration = 3600

  admin_events_enabled         = false
  admin_events_details_enabled = false
}

resource "keycloak_realm_default_client_scopes" "default_scopes" {
  realm_id = keycloak_realm.realm.id

  default_scopes = [
    "acr",
    "basic",
    "email",
    "profile",
    "role_list",
    "roles",
    "saml_organization",
    "web-origins",
  ]
}

resource "keycloak_realm_optional_client_scopes" "optional_scopes" {
  realm_id = keycloak_realm.realm.id

  optional_scopes = [
    "address",
    "offline_access",
    "microprofile-jwt",
    "organization",
    "phone",
  ]
}

resource "keycloak_openid_client_scope" "groups" {
  realm_id               = keycloak_realm.realm.id
  name                   = "groups"
  description            = "When requested, this scope will map a user's group memberships to a claim"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "group-membership-mapper"
  claim_name      = "groups"
  full_path       = false
}

resource "keycloak_openid_client" "grafana" {
  realm_id  = keycloak_realm.realm.id
  client_id = "grafana"

  name    = "grafana"
  enabled = true

  client_secret = "fDkjsTd9ltjfqVlKOhdrunsT2I6kqNf2"

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  valid_redirect_uris = ["*"]
  web_origins         = ["*"]
}

resource "keycloak_openid_client_default_scopes" "grafana_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.grafana.id

  default_scopes = [
    "email",
    "profile",
    "roles",
    "offline_access",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_openid_client_optional_scopes" "grafana_client_optional_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.grafana.id

  optional_scopes = []
}

resource "keycloak_openid_client" "semaphore" {
  realm_id  = keycloak_realm.realm.id
  client_id = "semaphore"

  name    = "semaphore"
  enabled = true

  client_secret = "M8Dgy4Z5I7s80TLiMp4rd7NNcH8c4DDC"

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  valid_redirect_uris = ["*"]
  web_origins         = ["*"]
}

resource "keycloak_openid_client" "gitea" {
  realm_id  = keycloak_realm.realm.id
  client_id = "gitea"

  name    = "gitea"
  enabled = true

  client_secret = "ggzIyvE7nsWDUA30BxPCeVyTsmsvns55"

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  valid_redirect_uris = ["*"]
  web_origins         = ["*"]
}

resource "keycloak_openid_client_default_scopes" "gitea_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.gitea.id

  default_scopes = [
    "basic",
    "email",
    "profile",
    "roles",
    "offline_access",
    "web-origins",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_openid_client_optional_scopes" "gitea_client_optional_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.gitea.id

  optional_scopes = ["acr", "address", "phone", "organization", "microprofile-jwt"]
}

resource "keycloak_ldap_user_federation" "ldap_user_federation" {
  name     = "chefops-ldap"
  vendor   = "AD"
  realm_id = keycloak_realm.realm.id
  enabled  = true

  edit_mode = "WRITABLE"

  connection_url     = "ldaps://windows-dc01.ad.chefops.local:636"
  use_truststore_spi = "NEVER"
  users_dn           = local.users_ou
  bind_dn            = "CN=svc-keycloak,CN=Managed Service Accounts,DC=ad,DC=chefops,DC=local"
  bind_credential    = "Keycloak123!"

  username_ldap_attribute = "sAMAccountName"
  rdn_ldap_attribute      = "cn"
  uuid_ldap_attribute     = "objectGUID"
  user_object_classes = [
    "person",
    "organizationalPerson",
    "user"
  ]

  trust_email         = true
  connection_timeout  = "5s"
  read_timeout        = "10s"
  full_sync_period    = 300
  changed_sync_period = 60
}

resource "keycloak_ldap_user_attribute_mapper" "ldap_user_attribute_mapper" {
  for_each = local.ldap_user_attributes

  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.ldap_user_federation.id
  name                    = "chefops-user-attribute-${each.key}"

  user_model_attribute        = each.key
  ldap_attribute              = each.value
  read_only                   = true
  always_read_value_from_ldap = true
  attribute_force_default     = true
}

resource "keycloak_ldap_group_mapper" "ldap_group_mapper" {
  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.ldap_user_federation.id
  name                    = "chefops-group-mapper"

  ldap_groups_dn            = local.chefops_ou
  group_name_ldap_attribute = "cn"
  group_object_classes = [
    "group"
  ]

  preserve_group_inheritance = false

  membership_attribute_type      = "DN"
  membership_ldap_attribute      = "member"
  membership_user_ldap_attribute = "sAMAccountName"
  memberof_ldap_attribute        = "memberOf"

  mode                         = "LDAP_ONLY"
  user_roles_retrieve_strategy = "LOAD_GROUPS_BY_MEMBER_ATTRIBUTE"

  mapped_group_attributes = ["description", "whenChanged", "whenCreated", "managedBy"]

  drop_non_existing_groups_during_sync = true
}

resource "keycloak_hardcoded_attribute_mapper" "email_verified" {
  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.ldap_user_federation.id
  name                    = "chefops-email_verified"
  attribute_name          = "emailVerified"
  attribute_value         = "true"
}

data "keycloak_realm" "master" {
  realm = "master"
}

data "keycloak_role" "default_roles_master" {
  realm_id = data.keycloak_realm.master.id
  name     = "default-roles-master"
}

data "keycloak_role" "admin_role" {
  realm_id = data.keycloak_realm.master.id
  name     = "admin"
}

resource "keycloak_user" "blackteam" {
  realm_id       = data.keycloak_realm.master.id
  username       = "black-team"
  enabled        = true
  email_verified = true
  last_name      = "DO NOT TOUCH"

  initial_password {
    value     = "dfgbfecn4uMtYxcqEdA3WQcdBgH2QGxM"
    temporary = false
  }
}

resource "keycloak_user_roles" "blackteam_user_roles" {
  realm_id   = data.keycloak_realm.master.id
  user_id    = keycloak_user.blackteam.id
  exhaustive = false

  role_ids = [
    data.keycloak_role.admin_role.id,
    data.keycloak_role.default_roles_master.id
  ]
}

resource "keycloak_user" "blueteam" {
  realm_id       = data.keycloak_realm.master.id
  username       = "keycloak_admin"
  enabled        = true
  email_verified = true
  last_name      = "Keycloak Admin"

  initial_password {
    value     = "admin"
    temporary = false
  }
}

resource "keycloak_user_roles" "blueteam_user_roles" {
  realm_id   = data.keycloak_realm.master.id
  user_id    = keycloak_user.blueteam.id
  exhaustive = false

  role_ids = [
    data.keycloak_role.admin_role.id,
    data.keycloak_role.default_roles_master.id
  ]
}
