#!/bin/bash

set -e

echo "Creating anonymous user with uid ${FTP_UID} gid ${FTP_GID} and home ${FTP_HOME}"

groupadd -g ${FTP_GID} ftp
useradd -u ${FTP_UID} -g ftp -d ${FTP_HOME} ftp

if [ -n ${UPLOAD_DIR_NAME} ] && [ ! -d "/${FTP_HOME}/${UPLOAD_DIR_NAME}" ]; then
  echo "Creating upload directory /${FTP_HOME}/${UPLOAD_DIR_NAME}"
  mkdir -p /${FTP_HOME}/${UPLOAD_DIR_NAME}
  chown ftp:ftp /${FTP_HOME}/${UPLOAD_DIR_NAME}
  chmod 777 /${FTP_HOME}/${UPLOAD_DIR_NAME}
fi

if [ "$#" -eq 0 ]; then
  FLAGS="-d -e -s -c 3 -C 3 -p ${PASV_PORTS}"
else
  FLAGS="$@"
fi

echo "Starting pure-ftpd with args: ${FLAGS}"
tail --pid $$ -F /var/log/pure-ftpd/pureftpd.log &
exec /bin/pure-ftpd $FLAGS

