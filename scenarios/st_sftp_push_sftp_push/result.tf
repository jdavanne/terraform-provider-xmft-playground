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

FOLDER="${xmft_st_subscription_ar.sub2.folder}"
TMPDIR=$(mktemp --directory)
DATE=$(date +'%Y%m%d_%H%M%S')
echo "Hello, World $DATE" >$TMPDIR/file.txt
FILENAME=file.txt-$DATE
SSHPASS=${xmft_st_account.account1.user.password_credentials.password} sshpass -e sftp -P ${local.st_sftp_port} -oBatchMode=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - ${xmft_st_account.account1.user.name}@${local.st_sftp_host} << !
   cd $FOLDER
   ls
   put $TMPDIR/file.txt $FOLDER/$FILENAME
   ls
   bye
!
echo $FILENAME
echo "Wait ST account2 to receive file..."
sleep 2
SSHPASS=${xmft_st_account.account2.user.password_credentials.password} sshpass -e sftp -P ${xmft_st_site_ssh.ssh1.port} -oBatchMode=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - ${xmft_st_account.account2.user.name}@${xmft_st_site_ssh.ssh1.host} << !
   ls
   get file.txt-$DATE $TMPDIR/found.txt
   bye
!
EOF
}

