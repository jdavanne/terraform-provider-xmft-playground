provider "xmft" {
  product  = "st"
  alias    = "st1"
  host     = "https://${local.st_admin_host}:8444"
  username = local.st_admin_username
  password = local.st_admin_password
}

resource "xmft_st_business_unit" "bu1" {
  provider    = xmft.st1
  name        = "bu1"
  base_folder = "${local.st_account_rootfs}/bu1"
}

resource "xmft_st_account" "account1" {
  provider      = xmft.st1
  name          = "account1${local.suffix}"
  business_unit = xmft_st_business_unit.bu1.name
  home_folder   = "${local.st_account_rootfs}/bu1/account1${local.suffix}"
  user = {
    name = "login1${local.suffix}"
    password_credentials = {
      password = "password1"
    }
  }
}

resource "xmft_st_advanced_routing_application" "ar1" {
  provider       = xmft.st1
  name           = "basic-ar1"
  type           = "AdvancedRouting"
  notes          = "generic tutu"
  business_units = []
}

resource "xmft_st_route_template" "template1" {
  provider       = xmft.st1
  name           = "basic-template1"
  description    = "generic template"
  business_units = []
}

resource "xmft_st_basic_application" "basic1" {
  provider       = xmft.st1
  name           = "basic-app1"
  notes          = "basic application"
  business_units = []
}

resource "xmft_st_sentinel" "sentinel1" {
  provider           = xmft.st1
  enabled            = false
  host               = "localhost"
  port               = "22"
  overflow_file_path = "/tmp/sentinel_overflow"
}

resource "tls_private_key" "rsa-1024-example" {
  algorithm = "RSA"
  rsa_bits  = 1024
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.rsa-1024-example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "xmft_st_certificate" "cert1" {
  provider = xmft.st1
  name     = "` + name + `"
  account  = xmft_st_account.account1.name
  type     = "x509"
  usage    = "login"
  #overwrite        = true
  content = tls_self_signed_cert.example.cert_pem
}
