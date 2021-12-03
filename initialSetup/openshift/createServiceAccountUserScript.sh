#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want
NUMBER_USERS=15
#
for NUM in $(seq 1 $NUMBER_USERS)
	do
	oc create serviceaccount -n default user$NUM
    oc create clusterrolebinding user$NUM --clusterrole=self-provisioners --serviceaccount=default:user$NUM
    oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:default:user$NUM
	done