#!/bin/bash
#
# Run this script with root privileges. Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want and their password. Replace PW with your password
NUMBER_USERS=15
PASSWORD=PW
#
# Install podman
yum install -y podman git
# Copy the download link for your operating system from the web console.
OC_DOWNLOAD_LINK=https://downloads-openshift-console.externaldemo-5115c94768819e85b5dd426c66340439-0000.eu-de.containers.appdomain.cloud/amd64/linux/oc.tar
#
# Get oc binary
wget $OC_DOWNLOAD_LINK
tar -xf oc.tar
chmod 777 oc
mv oc /usr/bin/
#
# Get latest version of Github repository
cd /root
git clone https://github.com/IBM/csm-dach-cloud-native-labs.git
#
# Create group + user
groupadd devUsers
chown root:devUsers /usr/bin/oc
for NUM in $(seq 1 $NUMBER_USERS)
	do
	useradd -G devUsers user$NUM
	echo user${NUM}:${PASSWORD} | chpasswd
	cp -R /root/csm-dach-cloud-native-labs /home/user${NUM}/
	chown -R user${NUM}:user${NUM} /home/user${NUM}/
	echo "Created user${NUM}"
	done
