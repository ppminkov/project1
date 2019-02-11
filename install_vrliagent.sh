# ReadMe: Make the script executable by 'chmode -R 755 <script_name>' and just execute it.
# The script should stop if an error arises.

PATCH_LOCATION='/tmp/vrliagent_6974218/'
PATCH_BINARY_1='/tmp/vrliagent_6974218/VMware-Log-Insight-Agent-4.6.0-6974218.noarch.rpm'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'

echo "=== Copying the patch folder ..."
if ! scp -r $PATCH_LOCATION  root@psrv12vro12.sccloudinfra.net:/tmp/ ; then echo "Cannot ssh to host 11"; exit 1; fi

echo "=== Current VRLI agent version is ..."
if ! rpm -qa | grep Log-Insight-Agent; then echo "VRLI agent version check failed"; exit 1; fi
sleep 5

echo "=== Installing the VRLI agent..."
if ! sudo rpm -Uvh $PATCH_BINARY_1; then echo "Installing the VRLIs failed"; exit 1; fi
sleep 5

echo "=== After upgrade VRLI agent version is..."
if ! rpm -qa | grep Log-Insight-Agent; then echo "VRLI agent version check failed"; exit 1; fi

echo -e "=== ${GREEN}The patch has been installed successfully!..."
