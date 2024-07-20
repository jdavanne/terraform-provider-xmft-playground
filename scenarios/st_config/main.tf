provider "xmft" {
  product  = "st"
  alias    = "st1"
  host     = "https://${local.st_admin_host}:8444"
  username = local.st_admin_username
  password = local.st_admin_password
}

locals {
  has_s3_plugin         = true
  has_azure_blob_plugin = true
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

resource "xmft_st_site_folder_monitoring" "site_folder_monitoring1" {
  provider = xmft.st1
  name     = "site_folder_monitoring1"
  account  = xmft_st_account.account1.name

  download_folder = "/download"
  upload_folder   = "/upload"
}

resource "xmft_st_site_ssh" "ssh1" {
  provider  = xmft.st1
  name      = "ssh1"
  account   = xmft_st_account.account1.name
  host      = "remote-host"
  port      = 22
  user_name = "username1"
  password  = "password1"
  #download_folder  = "/download"
  upload_folder = "/"
}

resource "xmft_st_site_pesit" "pesit1" {
  provider        = xmft.st1
  name            = "ST1"
  account         = xmft_st_account.account1.name
  host            = "remote-host"
  port            = 1761
  server_password = "ST1*"
}

resource "xmft_st_site_custom" "s3_sample" {
  count    = local.has_s3_plugin ? 1 : 0
  provider = xmft.st1
  name     = "s3_sample"
  protocol = "s3"
  account  = xmft_st_account.account1.name
  custom_properties = {
    s3Bucket                   = "mybucket",
    s3Region                   = "eu-west-3",
    s3AccessKey                = "accesskey",
    s3SecretKey                = "secretkey",
    s3DownloadObjectKey        = "/s3_download",
    s3VerifyCertificateEnabled = "true",
    s3SslCipherSuites          = "TLS_AES_256_GCM_SHA384, TLS_AES_128_GCM_SHA256, TLS_CHACHA20_POLY1305_SHA256, TLS_AES_128_CCM_SHA256, TLS_AES_128_CCM_8_SHA256, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_DHE_RSA_WITH_AES_256_GCM_SHA384, TLS_DHE_DSS_WITH_AES_256_GCM_SHA384, TLS_DHE_DSS_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_256_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_GCM_SHA256, TLS_DHE_DSS_WITH_AES_128_GCM_SHA256, TLS_DHE_DSS_WITH_AES_128_CBC_SHA256, TLS_DHE_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA256"
  }
}

resource "xmft_st_transfer_profile" "profile1" {
  provider          = xmft.st1
  name              = "FLOW1"
  transfer_mode     = "BINARY"
  account           = xmft_st_account.account1.name
  file_label_option = "SEND_FILENAME"
  depends_on        = [xmft_st_site_pesit.pesit1]
}

resource "xmft_st_user_class" "userclass1" {
  provider  = xmft.st1
  name      = "userclass1"
  user_type = "real"
  user_name = "user1"
  group     = "group1"
  address   = "192.168.1.1"
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

resource "xmft_st_subscription_ar" "sub1" {
  provider    = xmft.st1
  account     = xmft_st_account.account1.name
  folder      = "/inbound"
  application = xmft_st_advanced_routing_application.ar1.name
}

resource "xmft_st_route_composite" "route_composite1" {
  provider       = xmft.st1
  name           = "route1"
  description    = "send to partner"
  route_template = xmft_st_route_template.template1.id
  subscriptions  = [xmft_st_subscription_ar.sub1.id]
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

resource "xmft_st_file_archiving" "archiving1" {
  provider       = xmft.st1
  archive_folder = "/tmp/archive"

  global_archiving_policy              = "enabled"
  delete_files_older_than              = 1
  delete_files_older_than_unit         = "days"
  maximum_file_size_allowed_to_archive = 0
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
  name     = "cert1sample"
  account  = xmft_st_account.account1.name
  type     = "x509"
  usage    = "login"
  #overwrite        = true
  content = tls_self_signed_cert.example.cert_pem
}

resource "xmft_st_admin_role" "role1" {
  provider          = xmft.st1
  name              = "role1"
  is_limited        = true
  is_bounce_allowed = true
  menus             = ["Server Log"]
}

resource "xmft_st_admin" "admin1" {
  provider   = xmft.st1
  name       = "admin1"
  role_name  = xmft_st_admin_role.role1.name
  is_limited = true
  parent     = "admin"
  password_credentials = {
    password = "mypassword1"
  }

  administrator_rights = {
    can_read_only    = false
    is_maker         = true
    can_create_users = true
    can_update_users = true
  }
  depends_on = [xmft_st_admin_role.role1]
}

locals {
  options = {
    "Ftp.preferBouncyCastleProvider"                                      = "false"
    "Http.preferBouncyCastleProvider"                                     = "false"
    "As2.preferBouncyCastleProvider"                                      = "false"
    "Ssh.preferBouncyCastleProvider"                                      = "false"
    "Pesit.preferBouncyCastleProvider"                                    = "false"
    "TM.preferBouncyCastleProvider"                                       = "false"
    "TransactionManager.fileIOBufferSizeInKB"                             = "256"
    "TransactionManager.syncFileToDiskEveryKB"                            = "100000"
    "TransactionManager.ThreadPools.ThreadPool.EventMonitor.maxThreads"   = "1024"
    "EventQueue.ThreadPools.ThreadPool.maxThreads"                        = "1024"
    "EventQueue.ThreadPools.AdvancedRouting.maxThreads"                   = "1024"
    "TransactionManager.ThreadPools.ThreadPool.ServerTransfer.maxThreads" = "1024"
    "TransactionManager.RuleEngine.pool"                                  = "64"
    "EventQueue.SizeLimit.maxQueueSize"                                   = "10000"
    "OutboundConnections.maxConnectionsPerHost"                           = "1024"
    "Cluster.nodeListRefreshTime"                                         = "10"
    "Cluster.Status.heartbeatTimeout"                                     = "60"
  }
}
resource "xmft_st_conf_option" "options" {
  for_each = local.options
  provider = xmft.st1
  name     = each.key
  value    = each.value
}
