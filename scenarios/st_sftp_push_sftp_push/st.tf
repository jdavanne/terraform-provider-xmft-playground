
provider "xmft" {
  product  = "st"
  alias    = "st1"
  host     = "https://${local.st_admin_host}:8444"
  username = local.st_admin_username
  password = local.st_admin_password
}

resource "xmft_st_account" "account1" {
  provider    = xmft.st1
  name        = "account1${local.suffix}"
  home_folder = "${local.st_account_rootfs}/account1${local.suffix}"
  user = {
    name = "login1${local.suffix}"
    password_credentials = {
      password = "password1"
    }
  }
}

resource "xmft_st_account" "account2" {
  provider    = xmft.st1
  name        = "account2${local.suffix}"
  home_folder = "${local.st_account_rootfs}/account2${local.suffix}"
  user = {
    name = "login2${local.suffix}"
    password_credentials = {
      password = "password2"
    }
  }
}

resource "xmft_st_advanced_routing_application" "ar1" {
  provider       = xmft.st1
  name           = "ar1"
  type           = "AdvancedRouting"
  notes          = "generic tutu"
  business_units = []
}

resource "xmft_st_route_template" "template1" {
  provider       = xmft.st1
  name           = "template1"
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
      transfer_site_expression = "${xmft_st_site_ssh.ssh1.name}#!#CVD#!#"
      max_parallel_clients     = 4
    }
  }]
}

resource "xmft_st_site_ssh" "ssh1" {
  provider  = xmft.st1
  name      = "ssh1"
  account   = xmft_st_account.account1.name
  host      = local.st_sftp_host
  port      = local.st_sftp_port
  user_name = xmft_st_account.account2.user.name
  password  = xmft_st_account.account2.user.password_credentials.password
  #download_folder  = "/download"
  upload_folder = "/"
}

