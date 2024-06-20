provider "xmft" {
  product  = "cft"
  alias    = "cft1"
  host     = local.cft_api_url1
  username = local.cft_admin_username
  password = local.cft_admin_password
}

resource "xmft_cftpart" "st1" {
  provider = xmft.cft1
  name     = "st1"
  prot     = "PESIT"
  sap      = "1761"

  nrpart  = upper(xmft_st_account.account1.name)
  nrpassw = "ST1*"
  nspart  = "ST1"
  #nspassw = "cft1*"

  tcp = [{
    id     = "1"
    cnxout = "100"
    host   = "st1"
  }]
}

resource "xmft_cftrecv" "flow1" {
  provider = xmft.cft1
  name     = "flow1"
  exec     = ""
  fname    = "/tmp/&IDTU"
  ftype    = "B"
}
