#!/bin/bash
##### EDITABLE BY USER to specify vCenter Server instance and backup destination. #####
VC_ADDRESS=172.16.14.50
VC_USER=administrator@vsphere.local
VC_PASSWORD=tmp-W21!
############################

# Authenticate with basic credentials.
curl -u "$VC_USER:$VC_PASSWORD" \
   -X POST \
   -k --cookie-jar cookies.txt \
   "https://$VC_ADDRESS/rest/com/vmware/cis/session"

## Get the list of all Backup Job
curl -k --cookie cookies.txt \
   -H 'Accept:application/json' \
   --globoff \
   "https://$VC_ADDRESS/rest/appliance/recovery/backup/job" \
   | python -mjson.tool \
   >response.json

## Retrieve the last backup job
ID=`jq -r -c '[ .value[0] ]' response.json`
ID=${ID:2:-2}                                   # Remove first and last two characters
echo "Backup Job ID: $ID"

## Get the status of the last backup job

curl -k --cookie cookies.txt \
   -H 'Accept:application/json' \
   --globoff \
   "https://$VC_ADDRESS/rest/appliance/recovery/backup/job/$ID" \
   > response.json

## Get backup status
STATUS=`jq -r -c '[ .value.state ]' response.json`
STATUS=${STATUS:2:-2}                                   # Remove first and last two characters
echo "Last Backup $ID completed with Status $STATUS"

rm -f response.json
rm -f cookies.txt