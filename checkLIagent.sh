#!/bin/bash

date=`date +'%Y-%m-%d %H:%M:%S'`
status=`/sbin/service liagentd status`

if [[ ${status} == *"running"* ]]; then
  echo "${date} LiAgent is up and running, all good!"
else
  echo "${date} LiAgent is down, we should probably start it"
  /sbin/service liagentd start
  status=`/sbin/service liagentd status`
  echo "${date} ${status}"
fi
