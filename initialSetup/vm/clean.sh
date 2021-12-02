#!/bin/bash
#
# Run this script with root privileges. Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you have to delete
NUMBER_USERS=15
#
# Delete group + user
groupdel devUsers
echo "Deleted group devUsers"
for NUM in $(seq 1 $NUMBER_USERS)
	do
	userdel user$NUM
    rm -fR /home/user$NUM
	echo "Deleted user${NUM}"
	done