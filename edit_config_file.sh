#!/bin/bash

FILE_TO_EDIT="/tmp/setenv.sh"
#/var/lib/vco/app-server/bin/setenv.sh

GREEN='\033[0;32m'
ORANGE='\033[0;33m'

echo "=== Back up the initial configuration"
if ! cp $FILE_TO_EDIT $FILE_TO_EDIT + "%Y-%m-%d-%m-%s"` ; then echo "Replace value failed"; exit 1; fi

# Update value
echo "=== Set a value..."
if ! sed -i -e 's/Disable SNIExtension/Enable SNIExtension/g' $FILE_TO_EDIT ; then echo "=== ${ORANGE} Replace value failed"; exit 1; fi
if ! sed -i -e 's/enableSNIExtension=false/enableSNIExtension=true/g' $FILE_TO_EDIT ; then echo "=== ${ORANGE}Replace value failed"; exit 1; fi

# Add new lines in the config file on rows 36 and 37
if ! sed -e '36i#Enable TSL1.1, TSL1.2' -i $FILE_TO_EDIT ; then echo "${ORANGE} Adding the new value failed"; exit 1; fi
if ! sed -e '37iJVM_OPTS="$JVM_OPTS -Dhttps.protocols=SSLv3,TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2"' -i $FILE_TO_EDIT ; then echo "${ORANGE} Adding the new value failed"; exit 1; fi

# Restart vco-server
#if ! service vco-server restart ; then echo "Replace value failed"; exit 1; fi

echo -e "=== ${GREEN}The configuration file has been modified successfully!..."