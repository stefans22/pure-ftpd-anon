#!/bin/bash

set -e

echo "Creating anonymous user with uid ${FTP_UID} and gid ${FTP_GID}"

groupadd -g ${FTP_GID} ftp
useradd -u ${FTP_UID} -g ftp -d /data ftp

if [ ! -d "/data" ]; then
  echo "Creating data directory. Warning: It seems you forgot to mount the volume! All data will be lost when the container dies!"
  mkdir /data
  chown ftp:ftp /data
fi

if [ -n ${UPLOAD_DIR_NAME} ] && [ ! -d "/data/${UPLOAD_DIR_NAME}" ]; then
  echo "Creating upload directory /data/${UPLOAD_DIR_NAME}"
  mkdir -p /data/${UPLOAD_DIR_NAME}
  chown ftp:ftp /data/${UPLOAD_DIR_NAME}
  chmod 777 /data/${UPLOAD_DIR_NAME}
fi


if [ "$#" -eq 0 ]; then
  echo "Starting pure-ftpd with default args"
  /bin/pure-ftpd -e -c 3 -C 3 -p ${PASV_PORTS}
else
  echo "Starting pure-ftpd with custom args"
  /bin/pure-ftpd "$@"
fi

