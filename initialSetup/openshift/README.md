# Initial OpenShift cluster setup

This is a step by step instruction how to setup the workshop infrastructure

### Download the oc binary

Log into your Openshift cluster's web console. Then click on the help icon in the top right corner. Follow the "Command line tools" link and download the binary for your operating system.

### Login to cluster

You get this information from the web console. Click on your user in the top right corner then on "Copy login command".

```
oc login --token=<YourToken> --server=<YourServer>
```

### Create users via serviceaccount

You can modify the amount of users by editing the script.

```
sh createServiceAccountUserScript.sh
```

Print all oc login commands.

```
sh getServiceAccountCreds.sh
```

### Additional Scripts

#### Clean up cluster

Run the following script to delete all user projects

```
sh clean.sh
```

### Alternative: Managed OpenShift on IBM Cloud

If managed OpenShift on IBM Cloud is used, then user management via htpasswd is not supported. Instead use the IBM Cloud Shell via the browser.

_This alternatie only works if each user has an IBMId._

Once users logged into the IBM Cloud web console, they can open the shell at: https://cloud.ibm.com/shell

Then run the following commands to continue using the oc CLI.

```
ibmcloud ks clusters
```

Copy the cluster name and paste it into the next command to replace the CLUSTERNAME variable

```
ibmcloud oc cluster config -c CLUSTERNAME --admin
```

From then on, the normal oc commands can be used like

```
oc whoami
```

To give users the right to create new projects and delete their own, assign the correct cluster-role to them. They will only be able to delete their own projects. Replace **USERNAME** with your preferred user.

```
oc adm policy add-cluster-role-to-user self-provisioner USERNAME
```
