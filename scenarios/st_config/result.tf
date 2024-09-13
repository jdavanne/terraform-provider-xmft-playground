resource "local_file" "result" {
  filename        = "./run.sh"
  file_permission = "0700"
  content         = <<EOF
#!/bin/bash
#
set -euo pipefail

info() {
  echo "INFO: $*" 1>&2
  "$@"
}

TMPDIR=$(mktemp --directory)
DATE=$(date +'%Y%m%d_%H%M%S')
echo "Hello, World $DATE" >$TMPDIR/file.txt
FILENAME=file.txt-$DATE
SSHPASS=${xmft_st_account.account1.user.password_credentials.password} sshpass -e sftp -P ${local.st_sftp_port} -oBatchMode=no -o HostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - ${xmft_st_account.account1.user.name}@${local.st_sftp_host} << !
   cd ${xmft_st_subscription_ar.sub1.folder}
   ls
   put $TMPDIR/file.txt ${xmft_st_subscription_ar.sub1.folder}/$FILENAME
   ls
   bye
!
echo $FILENAME
EOF
}
