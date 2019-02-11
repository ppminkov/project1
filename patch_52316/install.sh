#!/bin/bash
# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# Just running a script
# The script should stop if an error arises.

PATCH_LOCATION='/tmp/patch_52316/'
PATCH_SCRIPT='/tmp/patch_5236/patch.sh'

GREEN='\033[0;32m'
ORANGE='\033[0;33m'



echo "=== Changing ownership ot the script ..."
if ! chown -R root $PATCH_SCRIPT; then echo "Changing ownership failed"; exit 1; fi
sleep 3

echo "=== Change the file permissions ot the script ..."
if ! chmod 744 $PATCH_SCRIPT; then echo "Change the file permissions failed"; exit 1; fi
sleep 3

echo "=== Running the script..."
if ! $PATCH_SCRIPT; then echo "Running the script failed"; exit 1; fi
sleep 10

echo "=== service xenon-service status"
if ! service xenon-service status; then echo "Install RPM1 failed"; exit 1; fi

echo -e "=== ${GREEN}The patch has been installed successfully!..."
echo -e "=== ${ORANGE}Don't forget to test it!..."

echo "=== Copying the patch to $appliance12..."
if ! scp -r $PATCH_LOCATION  root@dsrv10vra11.sccloudinfra.net:/tmp/ ; then echo "Cannot ssh to host 12"; exit 1; fi
#if ! scp -r $PATCH_LOCATION  root@dsrv10vra13.sccloudinfra.net:/tmp/ ; then echo "Cannot ssh to host 13"; exit 1; fi
