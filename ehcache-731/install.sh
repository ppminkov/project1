#!/bin/bash
# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# The script will stop if an error arises.
# Backups the files keeping the ownership
# Replacing the files keep the destination ownership and privileges

INSTALLFOLDER1="/opt/vmware/horizon/workspace/bin/"
INSTALLFOLDER2="/etc/bootstrap/everyboot.d/"
FILE1="setenv.sh"
FILE2="03-vidm-cluster-access-iptables"
SOURCEFOLDER="/tmp/ehcache-731/"
BACKUPFOLDER="/tmp/ehcache-731/backup/"
GREEN='\033[0;32m'
ORANGE='\033[0;33m'

if ! service horizon-workspace stop; then echo "horizon-workspace service stop failed!"; exit 1; fi
sleep 12

#back up the files
echo "Back up $FILE1 fo $BACKUPFOLDER..."
if ! cp -p $INSTALLFOLDER1$FILE1 $BACKUPFOLDER; then echo "Backup $FILE1 from $INSTALLFOLDER failed"; exit 1; fi
echo "Back up $FILE2 to $BACKUPFOLDER..."
if ! cp -p $INSTALLFOLDER2$FILE2 $BACKUPFOLDER; then echo "Backup $FILE2 from $INSTALLFOLDER failed"; exit 1; fi

#if ! service horizon-workspace stop; then echo "horizon-workspace service stop failed!"; exit 1; fi
#sleep 10

echo "Replacing the new files: $FILE1 to $INSTALLFOLDER1"
if ! cp --no-preserve=mode,ownership $SOURCEFOLDER$FILE1 $INSTALLFOLDER1; then echo "Replace $FILE1 failed"; exit 1; fi
echo "Replacing the new files: $FILE2 to $INSTALLFOLDER2"
if ! cp --no-preserve=mode,ownership $SOURCEFOLDER$FILE2 $INSTALLFOLDER2; then echo "Replace $FILE2 failed"; exit 1; fi

if ! service horizon-workspace start; then echo "horizon-workspace service start failed!"; exit 1; fi
sleep 15

echo -e "=== ${GREEN}The patch has been installed successfully!..."
echo -e "=== ${ORANGE}Don't forget to test it!..."
