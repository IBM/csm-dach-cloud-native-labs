### Welcome to the CSM DACH Team Cloud Native Labs!

We have an environment ready for you. 

Prerequisites:
 * You got an user number from the lab teacher
 * You got the password from the lab teacher
 * You can open a SSH connection to our classroom VM

To log in, just run the following command, replacing the "1" with your user number:
```
eramon:~$ ssh user1@158.177.83.155
user1@158.177.83.155's password: 
```
Alternatively, you can SSH to an alternative port, in case your firewall prevents to connect to the standard one:
```
eramon:~$ ssh -p 32122 user1@158.177.83.155
user1@158.177.83.155's password: 
```
Once logged in, check that podman is working:
```
[user1@external-demo ~]$ podman --version
podman version 3.3.1
```

Then check that oc is working:
```
[user1@external-demo ~]$ oc version
Client Version: 4.7.0-202110121415.p0.git.25914b8.assembly.stream-25914b8
``` 

You are all set. Have fun with the labs.

