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

Create a new conf under /etc/ssh/ssh_config.d/ to add whatever port you want.

```
echo "Port 5000" > /etc/ssh/ssh_config.d/customPort.conf
```

Enable custom ssh port through SELinux + firewall

```
dnf install -y policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp 5000
firewall-cmd --add-port=2021/tcp --permanent
firewall-cmd --reload
systemctl reload sshd
```

### Download the oc binary, create group + users

Run the setup script

```
sh createSetupScript.sh
```
