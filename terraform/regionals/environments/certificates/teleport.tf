# Used for initial Teleport setup
resource "tls_private_key" "teleport" {
  algorithm = "RSA"
}

resource "acme_registration" "teleport" {
  account_key_pem = tls_private_key.teleport.private_key_pem
  email_address   = "noreploy+acme26r@neccdl.org"
}

resource "acme_certificate" "teleport" {
  account_key_pem = acme_registration.teleport.account_key_pem
  common_name     = "teleport.chefops.tech"

  subject_alternative_names = [
    "teleport.chefops.tech",
    "*.teleport.chefops.tech"
  ]

  dns_challenge {
    provider = "route53"

    config = {
      AWS_PROFILE = "neccdc"
    }
  }
}


resource "local_file" "teleport_private_key_pem" {
  content  = acme_certificate.teleport.private_key_pem
  filename = "../../../../documents/black_team/certificates/teleport/private.key"
}

resource "local_file" "teleport_issuer" {
  content  = acme_certificate.teleport.issuer_pem
  filename = "../../../../documents/black_team/certificates/teleport/cabundle.crt"
}

resource "local_file" "teleport_cert" {
  content  = acme_certificate.teleport.certificate_pem
  filename = "../../../../documents/black_team/certificates/teleport/cert.crt"
}

resource "local_file" "teleport_fullchain" {
  content  = "${acme_certificate.teleport.certificate_pem}${acme_certificate.teleport.issuer_pem}"
  filename = "../../../../documents/black_team/certificates/teleport/fullchain.crt"
}
