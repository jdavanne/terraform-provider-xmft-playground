resource "local_file" "result" {
  filename        = "./run.sh"
  file_permission = "0700"
  content         = <<EOF
#!/bin/bash
#
set -euo pipefail
TMPDIR=$(mktemp --directory)
DATE=$(date +'%Y%m%d_%H%M%S')
echo "Hello, World $DATE" >$TMPDIR/file.txt
FILENAME=file.txt-$DATE
SSHPASS=${xmft_st_account.account1.user.password_credentials.password} sshpass -e sftp -P ${local.st_sftp_port} -oBatchMode=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - ${xmft_st_account.account1.user.name}@${local.st_sftp_host} << !
   cd ${xmft_st_subscription_ar.sub2.folder}
   ls
   put $TMPDIR/file.txt ${xmft_st_subscription_ar.sub2.folder}/$FILENAME
   ls
   bye
!
echo $FILENAME
echo "Wait CFT to receive file..."
for i in $(seq 1 10); do
  echo "Try $i..."
  sleep 0.2
  curl -s -k -u ${local.cft_admin_username}:${local.cft_admin_password} "${local.cft_api_url1}/cft/api/v1/transfers?idf=${xmft_st_transfer_profile.profile1.name}&fields=NFNAME,NSPART,NRPART,STATE,DATEB,TIMEB" | jq '.transfers[] | select(.nfname == "'"$FILENAME"'")' 
  r="$(curl -s -k -u ${local.cft_admin_username}:${local.cft_admin_password} "${local.cft_api_url1}/cft/api/v1/transfers?idf=${xmft_st_transfer_profile.profile1.name}&fields=NFNAME,NSPART,NRPART,STATE,DATEB,TIMEB" | jq -r '.transfers[] | select(.nfname == "'"$FILENAME"'")' )"
  if [ -n "$r" ]; then
    echo "Found!"
    exit 0
  fi
done
exit 1
EOF
}
