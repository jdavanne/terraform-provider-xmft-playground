resource "local_file" "result" {
  filename        = "./run.sh"
  file_permission = "0700"
  content         = <<EOF
#!/bin/bash
#
set -euo pipefail
DATE=$(date +'%Y%m%d_%H%M%S')
curl -k -u ${local.cft_admin_username}:${local.cft_admin_password} "${local.cft_api_url1}/cft/api/v1/transfers/files/outgoings?part=${xmft_cftpart.cft2.name}&idf=${xmft_cftsend.flow1.name}" \
  -X POST  \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{ "parm":"rand", "ida":"'test-$DATE'" }'
sleep 1
curl -k -u ${local.cft_admin_username}:${local.cft_admin_password} "${local.cft_api_url1}/cft/api/v1/transfers?ida=test-$DATE" | jq .
EOF
}
