#!/bin/bash
#
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many projects you want to create
NUMBER_PROJECTS=15
#
# Openshift credentials. Replace TOKEN and SERVER with your credentials
OC_TOKEN=TOKEN
OC_SERVER=SERVER
#
oc login --token=${OC_TOKEN} --server=${OC_SERVER}
for NUM in $(seq 1 $NUMBER_PROJECTS)
	do
	oc new-project user$NUM
	echo "Created project user${NUM}"
	done