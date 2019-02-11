#!/bin/bash
# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# The script should stop if an error arises.

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
FolderToBeBackedUp="/Users/pminkov/Documents/workspace/gitprj1/scripts/patch-test"
BackUpLocationPath="/Users/pminkov/Desktop/"
BackUpFolder="backup"

# TODO:echo "=== stopping vcac service..."
# TODO: if ! service vcac-server stop; then echo "command failed"; exit 1; fi
# TODO:sleep 20

echo "=== Create backup folder..."
#Creates folder in location
if ! mkdir "$BackUpLocationPath$BackUpFolder"; then echo "mkdir failed"; exit 1; fi
#Moves the folder
echo "=== Moving the folder..."
if ! mv "$FolderToBeBackedUp" "$BackUpLocationPath$BackUpFolder"; then echo "command failed"; exit 1; fi

echo -e "=== ${GREEN}Success!"

# echo "=== copy the new wars to webapps..."
# if ! cp /tmp/vRA_73_HF_2085826/iaas-proxy-provider.war /usr/lib/vcac/server/webapps/; then echo "command failed"; exit 1; fi
# if ! cp /tmp/vRA_73_HF_2085826/network-service.war /usr/lib/vcac/server/webapps/; then echo "command failed"; exit 1; fi
# sleep 2

# echo "=== fix the war rights..."
# if ! chmod -R 755 /usr/lib/vcac/server/webapps/iaas-proxy-provider.war; then echo "command failed"; exit 1; fi
# if ! chmod -R 755 /usr/lib/vcac/server/webapps/network-service.war; then echo "command failed"; exit 1; fi
# sleep 2

# echo "=== Extracting the archives..."
# if ! unzip -qq /usr/lib/vcac/server/webapps/iaas-proxy-provider.war -d /usr/lib/vcac/server/webapps/iaas-proxy-provider/; then echo "command failed"; exit 1; fi
# sleep 2
# if ! unzip -qq /usr/lib/vcac/server/webapps/network-service.war -d /usr/lib/vcac/server/webapps/network-service/; then echo "command failed"; exit 1; fi
# sleep 2

# echo "=== fix folder rights..."
# if ! chmod -R 755 /usr/lib/vcac/server/webapps/iaas-proxy-provider; then echo "command failed"; exit 1; fi
# if ! chmod -R 755 /usr/lib/vcac/server/webapps/network-service; then echo "command failed"; exit 1; fi
# sleep 2

# echo "=== deleting the wars..."
# if ! rm /usr/lib/vcac/server/webapps/iaas-proxy-provider.war; then echo "command failed"; exit 1; fi
# if ! rm /usr/lib/vcac/server/webapps/network-service.war; then echo "command failed"; exit 1; fi

# echo "=== Starting vcac service..."
# if ! service vcac-server start; then echo "command failed"; exit 1; fi

# echo -e "=== ${GREEN}The patch has been installed successfully!..."
# echo -e "=== ${ORANGE}Don't forget to test it!..."
