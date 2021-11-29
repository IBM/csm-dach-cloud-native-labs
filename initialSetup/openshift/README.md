# Initial OpenShift cluster setup

This is a step by step instruction how to setup the workshop infrastructure

### Download the oc binary

Log into your Openshift cluster's web console. Then click on the help icon in the top right corner. Follow the "Command line tools" link and download the binary for your operating system.

### Login to cluster

You get this information from the web console. Click on your user in the top right corner then on "Copy login command".

```
oc login --token=<YourToken> --server=<YourServer>
```

### Create users via htpasswd file

Optional: modify the amount of users and the password inside the script.

```
chmod 744 createUserScript.sh
touch htpasswd
sh createUserScript.sh
```

Verify that the password is set correctly

```
htpasswd -vb htpasswd user1 superSecure
```

### Create secret based on htpasswd file

Run this command inside the folder where the htpasswd file is located

```
oc create secret generic htpasswd-secret --from-file htpasswd=$(pwd)/htpasswd -n openshift-config
```

```
oc apply -f HTPasswdCR.yaml
```
