provider "xmft" {
  product  = "cft"
  alias    = "cft1"
  host     = local.cft_api_url1
  username = local.cft_admin_username
  password = local.cft_admin_password
}

provider "xmft" {
  product  = "cft"
  alias    = "cft2"
  host     = local.cft_api_url2
  username = local.cft_admin_username
  password = local.cft_admin_password
}

resource "xmft_cftsend" "flow1" {
  provider = xmft.cft1
  name     = "flow1"
  exec     = ""
  fcode    = "ASCII"
  faction  = "NONE"
  parm     = ""
  preexec  = ""
  fname    = "pub/FTEST"
  ftype    = "B"
}

resource "xmft_cftrecv" "flow1" {
  provider = xmft.cft2
  name     = "flow1"
  exec     = ""
  fname    = "/tmp/&IDTU"
  ftype    = "B"
}


resource "xmft_cftpart" "cft2" {
  provider = xmft.cft1
  name     = "cft2"
  prot     = "PESIT"
  sap      = local.cft_pesit_port2

  nrpart  = "CFT2"
  nrpassw = "cft2*"
  nspart  = "CFT1"
  nspassw = "cft1*"

  tcp = [{
    id     = "1"
    cnxout = "100"
    host   = local.cft_host2
  }]
}

resource "xmft_cftpart" "cft1" {
  provider = xmft.cft2
  name     = "cft1"
  prot     = "PESIT"
  sap      = local.cft_pesit_port1

  nrpart  = "CFT1"
  nrpassw = "cft1*"
  nspart  = "CFT2"
  nspassw = "cft2*"

  tcp = [{
    id     = "1"
    cnxout = "100"
    host   = local.cft_host1
  }]
}

