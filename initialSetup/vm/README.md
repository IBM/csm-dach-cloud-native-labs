## Set up a clean enviroment for the workshop

### Prerequisites

Install Ansible on your Red Hat Enterprise Linux host.

```
sudo yum -y install ansible
```

Create an ansible user with sudo privileges on your managed host, which doesn't require a password to elevate privileges

```
sudo useradd ansible
sudo passwd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
```

Create ssh keys and copy the public key to all remote hosts you wish to manage. Replace **MYHOST** with your remote host e.g. 192.168.1.2

```
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_ansible
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@MYHOST
```

### Clone the repository

```
raphael@desktop:~$ git clone https://github.com/IBM/csm-dach-cloud-native-labs.git
raphael@desktop:~$ cd csm-dach-cloud-native-labs/initialSetup/vm/
```

### Add your ansible managed vm

In the [inventory](inventory) file, replace the example IP address with your vm's IP or FQDN.

Do **NOT remove** the ansible_port or ansible_ssh_private_key_file.

```
[workstation]
192.168.122.136 ansible_port="{{ ssh_port }}" ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible
```

### Set a password for the workshop users

You first need to **set a password for the Ansible vault**. When later running the playbook, you need this password again.

```
raphael@desktop:~$ ansible-vault create password.yml
New Vault password:
Confirm New Vault password:
```

Enter your password to the key **password** in the following format:

```yaml
password: myPassword
```

### Run the Ansible playbook

The remote host will be **reset** to its previous state. All workshop users and their home directories will be deleted!

```
raphael@desktop:~$ ansible-playbook playbook.yml --vault-id password.yml@prompt
```

The VM is now ready for the workshop.

### Part 2. During the workshop

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
