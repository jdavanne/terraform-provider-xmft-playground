locals {
  envs               = { for tuple in regexall("(.*) *= *\"(.*)\"", file("../.env")) : tuple[0] => tuple[1] }
  st_admin_host      = local.envs["ST_ADMIN_HOST"]
  st_sftp_host       = local.envs["ST_SFTP_HOST"]
  st_sftp_port       = local.envs["ST_SFTP_PORT"]
  st_admin_username  = local.envs["ST_ADMIN_USERNAME"]
  st_admin_password  = local.envs["ST_ADMIN_PASSWORD"]
  st_account_rootfs  = local.envs["ST_ACCOUNT_ROOTFS"]
  suffix             = local.envs["SUFFIX"]
  cft_api_url1       = local.envs["CFT_API_URL1"]
  cft_api_url2       = local.envs["CFT_API_URL2"]
  cft_host           = local.envs["CFT_HOST"]
  cft_port_pesit     = local.envs["CFT_PORT_PESIT"]
  cft_admin_username = local.envs["CFT_ADMIN_USERNAME"]
  cft_admin_password = local.envs["CFT_ADMIN_PASSWORD"]
}
 
