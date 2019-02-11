#!/bin/bash
for i in {1..3}
do
  sudo -u postgres psql -d vcac -f purgeTokens.sql
  echo "Executing command $i"
done