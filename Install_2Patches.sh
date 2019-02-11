#!/bin/bash
# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# The script will stop if an error arises.

GREEN='\033[0;32m'
ORANGE='\033[0;33m'

PatchFileName="iaas-proxy-provider.war"
PatchFileName1="reservation-service.war"
BackUpFolder="/tmp/iaas-proxy-provider-backup"
BackUpFolder1="/tmp/reservation-service-backup"
InstallFolder="/usr/lib/vcac/server/webapps/iaas-proxy-provider"
InstallFolder1="/usr/lib/vcac/server/webapps/reservation-service"
WarCopyDestinationFolder="/usr/lib/vcac/server/webapps/"
PatchSourceFolder="/tmp/patch_21430021"

echo "=== Stopping vcac-server service..."
if ! service vcac-server stop; then echo "vcac-server stop command failed"; exit 1; fi
sleep 20

echo "Create BackUp folder"
if ! mkdir $BackUpFolder; then echo "Backup folder:$BackUpFolder creation failed"; exit 1; fi
if ! mkdir $BackUpFolder1; then echo "Backup folder:$BackUpFolder1 creation failed"; exit 1; fi

echo "=== Moving up the content to $BackUpFolder... but the src folder stays with rights. /* copies the content of a folder"
if ! mv $InstallFolder/* $BackUpFolder; then echo "Backup failed"; exit 1; fi
if ! mv $InstallFolder1/* $BackUpFolder1; then echo "Backup 1 failed"; exit 1; fi

sleep 5

echo "=== Copy the new wars to installation folder..."
if ! cp $PatchSourceFolder/$PatchFileName $WarCopyDestinationFolder; then echo "war copy failed"; exit 1; fi
if ! cp $PatchSourceFolder/$PatchFileName1 $WarCopyDestinationFolder; then echo "war copy 1 failed"; exit 1; fi
sleep 2 

echo "=== fix the war rights..."
if ! chmod -R 755 $WarCopyDestinationFolder/$PatchFileName; then echo "fix the war rights failed"; exit 1; fi
if ! chmod -R 755 $WarCopyDestinationFolder/$PatchFileName1; then echo "fix the war 1 rights failed"; exit 1; fi
sleep 2

#echo "=== Make an installation folder..."
#if ! mkdir $InstallFolder; then echo "mkdir installation folder failed"; exit 1; fi
#sleep 2

echo "=== Extracting the wars..."
if ! unzip -qq $PatchSourceFolder/$PatchFileName -d $InstallFolder; then echo "Unarchival failed"; exit 1; fi
if ! unzip -qq $PatchSourceFolder/$PatchFileName1 -d $InstallFolder1; then echo "Unarchival 1 failed"; exit 1; fi
sleep 5

echo "=== fix folder rights..."
if ! chmod -R 755 $InstallFolder; then echo "fix the war rights failed"; exit 1; fi
if ! chmod -R 755 $InstallFolder1; then echo "fix the war 1 rights failed"; exit 1; fi
sleep 2 

echo "=== deleting the wars..."
if ! rm $WarCopyDestinationFolder$PatchFileName; then echo "deleting the war failed"; exit 1; fi
if ! rm $WarCopyDestinationFolder$PatchFileName1; then echo "deleting the war failed"; exit 1; fi
sleep 5

echo "=== Starting vcac-server service..."
if ! service vcac-server start; then echo "vcac-server start command failed"; exit 1; fi
sleep 20

echo -e "=== ${GREEN}The patch has been installed successfully!..."
echo -e "=== ${GREEN}And the patch 2 has been installed successfully!..."
echo -e "=== ${ORANGE}Don't forget to test it!..."
