#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want
NUMBER_USERS=15
#
for NUM in $(seq 1 $NUMBER_USERS)
	do
	htpasswd -B -b htpasswd user$NUM superSecure
	done