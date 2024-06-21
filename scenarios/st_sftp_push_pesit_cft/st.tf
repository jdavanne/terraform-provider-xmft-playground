locals {
  scenario = "stpesitcft"
}

provider "xmft" {
  product  = "st"
  alias    = "st1"
  host     = "https://${local.st_admin_host}:8444"
  username = local.st_admin_username
  password = local.st_admin_password
}

resource "xmft_st_account" "account1" {
  provider    = xmft.st1
  name        = "account46" #-${local.scenario}${local.suffix}"
  home_folder = "${local.st_account_rootfs}/account1${local.scenario}${local.suffix}"
  user = {
    name = "login1-${local.scenario}${local.suffix}"
    password_credentials = {
      password = "password1"
    }
  }
}

resource "xmft_st_advanced_routing_application" "ar1" {
  provider       = xmft.st1
  name           = "ar1-${local.scenario}"
  type           = "AdvancedRouting"
  notes          = "generic tutu"
  business_units = []
}

resource "xmft_st_route_template" "template1" {
  provider       = xmft.st1
  name           = "template1-${local.scenario}"
  description    = "generic template"
  business_units = []
}

resource "xmft_st_subscription_ar" "sub2" {
  provider    = xmft.st1
  account     = xmft_st_account.account1.name
  folder      = "/inbox"
  application = xmft_st_advanced_routing_application.ar1.name
}

resource "xmft_st_route_composite" "route_composite1" {
  provider       = xmft.st1
  name           = "route1"
  description    = "send to partner"
  route_template = xmft_st_route_template.template1.id
  subscriptions  = [xmft_st_subscription_ar.sub2.id]
  account        = xmft_st_account.account1.name

  steps = [{
    execute_route_id = xmft_st_route_simple.simple1.id
    }
  ]
}

resource "xmft_st_route_simple" "simple1" {
  name     = "simple1"
  provider = xmft.st1
  steps = [{
    send_to_partner = {
      transfer_site_expression         = "${xmft_st_site_pesit.pesit2.name}#!#CVD#!#"
      transfer_profile_expression      = xmft_st_transfer_profile.profile1.name
      transfer_profile_expression_type = "NAME"
      max_parallel_clients             = 4
    }
  }]
}

resource "xmft_st_transfer_profile" "profile1" {
  provider          = xmft.st1
  name              = "FLOW1"
  transfer_mode     = "BINARY"
  account           = xmft_st_account.account1.name
  file_label_option = "SEND_FILENAME"
  depends_on        = [xmft_st_site_pesit.pesit2]
}

resource "xmft_st_site_pesit" "pesit2" {
  provider        = xmft.st1
  name            = "ST1"
  account         = xmft_st_account.account1.name
  host            = local.cft_host1
  port            = local.cft_pesit_port1
  server_password = "ST1*"
}
