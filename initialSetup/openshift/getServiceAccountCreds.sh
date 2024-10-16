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
    TOKEN=$(oc -n default get secret $(oc get secret -n default | grep -m1 user1-dockercfg | awk '{print $1}') -o jsonpath='{.data.\.dockercfg}' | base64 --decode | jq -r 'to_entries[0].value.auth' | base64 --decode | cut -d':' -f2)
	echo -e "Token User $NUM:\noc login --token=$TOKEN --server=$SERVER\n\n"
	done
