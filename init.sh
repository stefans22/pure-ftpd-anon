#!/bin/bash

set -e

echo "Creating anonymous user with uid ${FTP_UID:=1000} and gid ${FTP_GID:=1000}"

groupadd -g ${FTP_GID:=1000} ftp
useradd -u ${FTP_UID:=1000} -g ftp -d /data ftp

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
  /bin/pure-ftpd -e -p ${PASV_PORTS:="30000:30005"}
else
  echo "Starting pure-ftpd with custom args"
  /bin/pure-ftpd "$@"
fi

