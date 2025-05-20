#!/bin/bash
# sh genToken.sh >> /tmp/login
# sh genToken.sh >> /tmp/login
# Report bugs at: https://github.com/IBM/csm-dach-cloud-native-labs/issues
#
# Choose how many users you want
NUMBER_USERS=20
#
SERVER=$(oc status | grep -m1 "In project" | awk '{print$6}')
for NUM in $(seq 1 $NUMBER_USERS); do
    USER="user${NUM}"
    TOKEN=$(oc create token ${USER} -n default)
    echo -e "Token User $NUM:\noc login --token=$TOKEN --server=$SERVER\n\n"
done
