#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many projects you need to delete
NUMBER_PROJECTS=15
#
# Openshift credentials. Replace TOKEN and SERVER with your credentials
OC_TOKEN=TOKEN
OC_SERVER=SERVER
#
oc login --token=${OC_TOKEN} --server=${OC_SERVER}
for NUM in $(seq 1 $NUMBER_PROJECTS)
	do
	oc delete project user$NUM
	echo "Deleted project user${NUM}"
	done