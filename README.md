# Experimental Only 

Playground to use xmft on various use cases 


- https://registry.terraform.io/providers/jdavanne/xmft
- https://github.com/jdavanne/terraform-provider-xmf

## Prerequisites

- 1 Secure Tranport for ST scenarios
- 2 CFTs for CFT scenarios
- terraform
- jq 

##

please fill `.env`file :

```sh
ST_ADMIN_HOST="<host>"
ST_ADMIN_URL="https://<host>:8444"
ST_SFTP_HOST="<host>"
ST_SFTP_PORT="8022"
ST_ADMIN_USERNAME="admin"
ST_ADMIN_PASSWORD="admin*"
ST_ACCOUNT_ROOTFS="/files"
SUFFIX= "21"
CFT_API_URL1="https://<host>:1768"
CFT_API_URL2="https://<host>:1769"
CFT_HOST1="<host>"
CFT_HOST2="<host>"
CFT_PESIT_PORT1="1761"
CFT_PESIT_PORT2="1762"
CFT_ADMIN_USERNAME="admin"
CFT_ADMIN_PASSWORD="changeit"
```

# EXPERIMENTAL

```sh
terraform init
terraform plan
terraform apply
terraform destroy
terraform destroy -refresh=false

terraform state list
terraform state rm <state>
terraform state rm $(terraform state list) #ouch
```