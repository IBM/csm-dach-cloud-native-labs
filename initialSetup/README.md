## Set up a clean enviroment for the workshop

### Part 1. On the VM

Following steps must be executed on the VM as administrator.

Log in:

```
eramon:~$ ssh -p 32122 eva@158.177.83.155
eva@158.177.83.155's password:
```

Clone repository and go into the directory:

```
[eva@external-demo ~]$ git clone https://github.com/IBM/csm-dach-cloud-native-labs.git
[eva@external-demo ~]$ cd csm-dach-cloud-native-labs/
[eva@external-demo csm-dach-cloud-native-labs]$
```

Run the _delete_ script to clean up actions from previous workshops:

```
[eva@external-demo csm-dach-cloud-native-labs]$ sudo sh initialSetup/vm/clean.sh
```

Run the _create user_ script to set up the user accounts on the VM:

```
[eva@external-demo csm-dach-cloud-native-labs]$ sh initialSetup/vm/createSetupScript.sh
```

Logout:

```
[eva@external-demo csm-dach-cloud-native-labs]$ exit
logout
Connection to 158.177.83.155 closed.
```

### Part 2. From your laptop

Delete the existing _workshop_ branch:
First list all branches and select which branch you want to delete. Make sure to delete both the remote and the local branch

```
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git branch -a
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git checkout main
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git push origin -d workshop
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git branch -D workshop
```

Re-create the _workshop_ branch based on the main branch:

```
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git branch workshop main
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git checkout workshop
[raphaeltholl@Raphaels-MacBook-Pro csm-dach-cloud-native-labs] % git push origin -u workshop

```
