#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want
NUMBER_USERS=15
#
SERVER=$(oc status | grep -m1 "In project" | awk '{print$6}')
for NUM in $(seq 1 $NUMBER_USERS)
	do
    TOKEN=$(oc -n default get secret $(oc get secret -n default | grep -m1 user${NUM}-token | awk '{print$1}') -o jsonpath='{.data.token}' | base64 --decode)
	echo -e "Token User $NUM:\noc login --token=$TOKEN --server=$SERVER\n\n"
	done