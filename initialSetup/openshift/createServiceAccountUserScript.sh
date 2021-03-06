#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want
NUMBER_USERS=15
#
oc adm groups new externals
for NUM in $(seq 1 $NUMBER_USERS)
	do
	oc create serviceaccount -n default user$NUM
	oc adm groups add-users externals user$NUM
	done
oc adm policy add-cluster-role-to-group self-provisioner externals
