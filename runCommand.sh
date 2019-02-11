#!/bin/bash
SCRIPT="ls; pwd"
HOSTS=("dsrv10vra11.sccloudinfra.net" "dsrv10vra12.sccloudinfra.net" "dsrv10vra13.sccloudinfra.net")


for HOSTNAME in ${HOSTS[*]} ; do
    ssh root@${HOSTNAME} "${SCRIPT}"
done