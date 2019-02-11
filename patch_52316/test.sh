#!/bin/bash
# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# The script should stop if an error arises.

PATCH_LOCATION='/tmp/patch_52316/'
PATCH_SCRIPT='/tmp/patch_52316/test.sh'

GREEN='\033[0;32m'
ORANGE='\033[0;33m'



echo "=== This is a test script ..."
echo "=== Running the script..."
if ! ./$PATCHSCRIPT; then echo "Running the script failed"; exit 1; fi
sleep 3

echo -e "=== ${GREEN}The patch has been installed successfully!..."
