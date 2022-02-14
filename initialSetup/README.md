## Set up a clean enviroment for the workshop

### Prerequisites

Install Ansible on your Red Hat Enterprise Linux

```
sudo yum -y install ansible
```

Create an ansible user with sudo privileges, which doesn't require a password to elevate privileges

```
sudo useradd ansible
sudo passwd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
```

Create ssh keys and the public key to all remote hosts you wish to manage. Replace **MYHOST** with your remote host e.g. 192.168.1.2

```
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_ansible
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@MYHOST
```

### Clone the repository

```
raphael@desktop:~$ git clone https://github.com/IBM/csm-dach-cloud-native-labs.git

```

### Set a password for the participant users

You first need to **set a password for the vault**. When later running the playbook, you need this password again.

```
raphael@desktop:~$ cd csm-dach-cloud-native-labs/initialSetup
raphael@desktop:~$ ansible-vault create password
New Vault password:
Confirm New Vault password:
```

Enter your password to the key **password** in the following format:

```yaml
password: myPassword
```

### Run the Ansible playbook

The remote host will be **reset** to its previous state!

```
raphael@desktop:~$ ansible-playbook playbook.yml

```

Change the default password, which is _PW_. Replace the _myPa55w0rD_ in this example with your own password!

```
[eva@external-demo csm-dach-cloud-native-labs]$ sed -i 's/PW/myPa55w0rD/g' initialSetup/vm/createSetupScript.sh
```

_For the next two steps, you'll need administrator rights_

Run the _delete_ script to clean up actions from previous workshops:

```
[eva@external-demo csm-dach-cloud-native-labs]$ sudo sh initialSetup/vm/clean.sh
```

Run the _create user_ script to set up the user accounts on the VM:

```
[eva@external-demo csm-dach-cloud-native-labs]$ sudo sh initialSetup/vm/createSetupScript.sh
```

The VM is now ready for the workshop.

Logout:

```
[eva@external-demo csm-dach-cloud-native-labs]$ exit
logout
Connection to 158.177.83.155 closed.
```

### Part 2. On your laptop

Delete the existing _workshop_ branch.

First list all branches and select which branch you want to delete. Make sure to delete both the remote and the local branch:

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

The git repository branch is now ready for the workshop.
