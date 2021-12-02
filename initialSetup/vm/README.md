# Initial VM setup

This is a step by step instruction how to setup the workshop infrastructure

## Create admin users

Replace "raphael" with your username

```
groupadd admin
useradd -G admin raphael
passwd raphael
echo "%admin ALL=(ALL) ALL" > /etc/sudoers.d/admins
```

### Security: Enable firewall + SELinux, add custom ssh port

```
setenforce enforcing
systemctl enable --now firewalld
```

Add custom ssh port to /etc/ssh/sshd_config

```
echo "Port 32122" >> /etc/ssh/sshd_config
```

Enable custom ssh port through SELinux + firewall

```
dnf install -y policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp 32122
firewall-cmd --add-port=32122/tcp --permanent
firewall-cmd --reload
systemctl reload sshd
```

### Download the oc binary, create group + users

Run the setup script

```
sh createSetupScript.sh
```

### Delete users + devUsers group

Run the clean script

```
sh clean.sh
```
