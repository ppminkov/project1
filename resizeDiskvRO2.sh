#!/bin/bash

function emit_status {
  if [ $1 -eq 0 ]; then
    echo " (done)"
  else
    echo " (failed)"
    exit $1
  fi
}

resizeLog="resize.log"

echo -e "\e[33m\n\nBefore using this script, make sure you have increased Disk2 size with minimum 25% from vCenter > VM Settings.\n\e[0m"

echo -e "\e[33m!!! In case of any issues, contact VMware support and provide resize.log file !!!\n\n\e[0m"

while true; do
    read -p "Please confirm that you have recent backup of this vRO VA appliance? (y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""

while true; do
    read -p "Do you want to resize /storage/log partition? (y/n)" yn
    case $yn in
        [Yy]* ) increaseLog=true; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""

while true; do
    read -p "Do you want to resize /storage/db partition? (y/n) " yn
    case $yn in
        [Yy]* ) increaseDb=true; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ""

if [ $increaseDb ] && [ $increaseLog ]; then
    echo "Increasing /storage/log and /storage/db partitions and maintaining current size ratio (8:2)."

    echo "Stopping vRO services"
    service vco-server stop 2>&1 >> ${resizeLog}
    service vco-configurator stop 2>&1 >> ${resizeLog}
    service vpostgres stop 2>&1 >> ${resizeLog}

    echo -n "Unmounting old database partition"
    umount /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Unmounting old log partition"
    umount /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new database partition"
    ( echo 80%; echo 100%;) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating filesystem on the new database partition"
    sleep 10
    mkfs.ext3 /dev/sdb3 2>&1 >> ${resizeLog}
    emit_status $? 

    echo -n "Mounting old and new database partitions"
    mkdir /mnt/sdb2 /mnt/sdb3 2>&1 >> ${resizeLog}
    mount /dev/sdb2 /mnt/sdb2/ && mount /dev/sdb3 /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?  

    echo -n "Copying data from old to new database partition"
    rsync -av /mnt/sdb2/* /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?  

    echo -n "Unmounting old and new database partitions"
    umount /dev/sdb2 && umount /dev/sdb3 2>&1 >> ${resizeLog}
    rmdir /mnt/sdb2 /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Deleting the new database partition"
    parted /dev/sdb rm 3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Deleting the old database partition"
    parted /dev/sdb rm 2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Deleting the old logs partition"
    parted /dev/sdb rm 1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new logs partition"
    ( echo 0%; echo 80%; ) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new database partition"
    ( echo 80%; echo 100%;) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Informing the kernel for partition changes the new partition"
    partprobe 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Validating the new logs partition filesystem"
    sleep 10
    e2fsck -f -y /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Validating the new database partition filesystem"
    e2fsck -f -y /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Resizing the logs partition filesystem"
    resize2fs /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Re-mounting the new partition"
    mount -a 2>&1 >> ${resizeLog}
    emit_status $?

    echo "Starting the vRO services"
    service vpostgres start 2>&1 >> ${resizeLog}
    service vco-server start 2>&1 >> ${resizeLog}
    service vco-configurator start 2>&1 >> ${resizeLog}

elif [ $increaseDb ]; then
    echo "Increasing only /storage/db partition with newly added Disk2 space."
    
    echo "Stopping vRO services"
    service vco-server stop 2>&1 >> ${resizeLog}
    service vco-configurator stop 2>&1 >> ${resizeLog}
    service vpostgres stop 2>&1 >> ${resizeLog}

    echo -n "Unmounting the old partition"
    umount /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Calculating the old partition startBlock"
    startBlock=`parted /dev/sdb print free | egrep '^\s+2' | awk '{print $2}'` 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Deleting the old partition"
    parted /dev/sdb rm 2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating the new partition"
    parted /dev/sdb mkpart primary ext3 ${startBlock} 100% 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Informing the kernel for partition changes the new partition"
    partprobe 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Validating the new partition filesystem"
    sleep 10
    e2fsck -f -y /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Resizing the new new partition filesystem"
    resize2fs /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Re-mounting the new partition"
    mount -a 2>&1 >> ${resizeLog}
    emit_status $?

    echo "Starting the vRO services"
    service vpostgres start 2>&1 >> ${resizeLog}
    service vco-server start 2>&1 >> ${resizeLog}
    service vco-configurator start 2>&1 >> ${resizeLog}    

elif [ $increaseLog ]; then
    echo "Increasing only /storage/log partition with newly added Disk2 space."

    echo "Stopping vRO services"
    service vco-server stop 2>&1 >> ${resizeLog}
    service vco-configurator stop 2>&1 >> ${resizeLog}
    service vpostgres stop 2>&1 >> ${resizeLog}

    echo -n "Unmounting old database partition"
    umount /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Unmounting old log partition"
    umount /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Calculating database partition size"
    dbSize=`parted /dev/sdb print free | egrep '^\s+2' | awk '{print $4}'` 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new database partition"
    ( echo -${dbSize}; echo 100%;) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating filesystem on the new database partition"
    sleep 10
    mkfs.ext3 /dev/sdb3 2>&1 >> ${resizeLog}
    emit_status $? 

    echo -n "Mounting old and new database partitions"
    mkdir /mnt/sdb2 /mnt/sdb3 2>&1 >> ${resizeLog}
    mount /dev/sdb2 /mnt/sdb2/ && mount /dev/sdb3 /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?  

    echo -n "Copying data from old to new database partition"
    rsync -av /mnt/sdb2/* /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?  

    echo -n "Unmounting old and new database partitions"
    umount /dev/sdb2 && umount /dev/sdb3 2>&1 >> ${resizeLog}
    rmdir /mnt/sdb2 /mnt/sdb3 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Deleting the new database partition"
    parted /dev/sdb rm 3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Deleting the old database partition"
    parted /dev/sdb rm 2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Deleting the old logs partition"
    parted /dev/sdb rm 1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new logs partition"
    ( echo 0%; echo -${dbSize}; ) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Creating new database partition"
    ( echo -${dbSize}; echo 100%;) | parted /dev/sdb mkpart primary ext3 2>&1 >> ${resizeLog}
    emit_status $?
    
    echo -n "Informing the kernel for partition changes the new partition"
    partprobe 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Validating the new logs partition filesystem"
    sleep 10
    e2fsck -f -y /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Validating the new database partition filesystem"
    e2fsck -f -y /dev/sdb2 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Resizing the logs partition filesystem"
    resize2fs /dev/sdb1 2>&1 >> ${resizeLog}
    emit_status $?

    echo -n "Re-mounting the new partition"
    mount -a 2>&1 >> ${resizeLog}
    emit_status $?

    echo "Starting the vRO services"
    service vpostgres start 2>&1 >> ${resizeLog}
    service vco-server start 2>&1 >> ${resizeLog}
    service vco-configurator start 2>&1 >> ${resizeLog}
else
    echo "Nothing to do."
fi