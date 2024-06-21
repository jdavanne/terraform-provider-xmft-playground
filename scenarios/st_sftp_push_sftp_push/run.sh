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
SSHPASS=password1 sshpass -e sftp -P 8022 -oBatchMode=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - login121@ci8.jda.axwaytest.net << !
   cd /inbox
   ls
   put $TMPDIR/file.txt /inbox/$FILENAME
   ls
   bye
!
echo $FILENAME
echo "Wait ST account2 to receive file..."
sleep 2
SSHPASS=password2 sshpass -e sftp -P 8022 -oBatchMode=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -b - login221@ci8.jda.axwaytest.net << !
   ls
   get file.txt-$DATE $TMPDIR/found.txt
   bye
!
