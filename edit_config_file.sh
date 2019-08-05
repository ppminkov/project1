#!/bin/bash
# edit a file with sed
# update a specific value
# adding an empty line at the end

FILE_TO_EDIT='/var/lib/vco/app-server/bin/setenv.sh'
BACKUP_DIR="/tmp/setenv`date +"%Y-%m-%d-%m-%s"`"
GREEN='\033[0;32m'
ORANGE='\033[0;33m'

echo "=== Back up the initial configuration"
if ! cp ${FILE_TO_EDIT} $BACKUP_DIR  ; then echo "Backup file failed"; exit 1; fi

# Update a value
echo "=== Set a value..."
if ! sed -i -e 's/Disable SNIExtension/Enable SNIExtension/g' $FILE_TO_EDIT ; then echo "=== ${ORANGE} Replace value failed"; exit 1; fi
if ! sed -i -e 's/enableSNIExtension=false/enableSNIExtension=true/g' $FILE_TO_EDIT ; then echo "=== ${ORANGE}Replace value failed"; exit 1; fi

# Add new lines in the config file on specific rows with new line at the end
echo "=== Adding new lines..."
if ! sed -e '36i#Enable TSL1.1, TSL1.2' -i $FILE_TO_EDIT ; then echo "${ORANGE} Adding the new line failed"; exit 1; fi
if ! sed -e '37iJVM_OPTS="$JVM_OPTS -Dhttps.protocols=SSLv3,TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2"\n' -i $FILE_TO_EDIT ; then echo "${ORANGE} Adding the new value failed"; exit 1; fi

# Restart vco-server
echo "=== Restarting vRO server to apply the changes..."
if ! service vco-server restart ; then echo "${ORANGE}VCO server restart failed"; exit 1; fi

echo -e "=== ${GREEN}The configuration changes have been done successfully!..."