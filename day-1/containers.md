
## Managing Images and Containers with Podman

The objective of this lab is to learn how to create and manage containers and images, using the _podman_ command line interface tool. We are going to work with two examples, a nginx web server and a mariadb database server. 

_Podman_ is a daemonless container engine for developing, managing and running OCI containers. 

### Table of contents

1. Example 1: Nginx
2. Example 2: MariaDB 

### 1. Nginx

Let's start pulling an image from a public registry. 

Images are kept in registries, which can be public or private:

 * _docker.io_ is an example of a public registry. Everyone can push images to docker.io, if they have an account. To pull public images, no account or login is necessary.
 * _registry.redhat.io_ and _quay.io_ are examples of registries which need authentication i.e. credentials, in order to use their images
 * There are also private registries, for example a registry used internally in a company

_In this lab, we'll use images from docker.io: to log in to the registry is not necessary._

_WARNING: every one is allowed to update images to Dockerhub, so use them with caution._

We want to run a nginx image. 

_Nginx is an open-source web application server_

We are pulling the bitnami/nginx image from docker.io:
```
podman pull quay.io/rhettibm/nginx
```
```
Trying to pull docker.io/bitnami/nginx:latest...
Getting image source signatures
...
```

_The bitnami images are rootless. Relying on rootless containers is a security best practice._

We can see that the image is now available locally:
```
podman images
```
```
REPOSITORY               TAG         IMAGE ID      CREATED      SIZE
docker.io/bitnami/nginx  latest      55027d4388b7  4 hours ago  94.7 MB
```

We just pulled the image, we did not create any container yet.

Run the image as a container:
```
podman run -d --name mynginx rhettibm/nginx
```
```
097ee94c96e5e6e1655ed688fbe043a14d769248bf907effc64bc740f8acfe49
```
 * The _-d_ parameter means _dettached_ so the image runs as daemon
 * the _--name_ parameter gives a name to the container. It is optional.

If we list the running containers, we'll see our new nginx container there:
```
podman ps
```
```
CONTAINER ID  IMAGE                           COMMAND               CREATED         STATUS             PORTS       NAMES
097ee94c96e5  docker.io/bitnami/nginx:latest  /opt/bitnami/scri...  44 seconds ago  Up 44 seconds ago              mynginx

```
Let's take a closer look. Every container has a command which runs upon start, called entrypoint. To find out the entrypoint of this nginx image, we inspect the details of the container:
```
podman inspect mynginx |less
```

We pipe the standard output to the command _less_ to be able to browse the information more confortably. Then we search for "Cmd" and we found this:
```
"Cmd": [
  "/opt/bitnami/scripts/nginx/run.sh"
  ]
```
That means that after the container is built the command script _run.sh_ is called which will start the nginx server.

Now we are going to delete the running container:
```
podman rm mynginx
```
```
Error: cannot remove container 097ee94c96e5e6e1655ed688fbe043a14d769248bf907effc64bc740f8acfe49 as it is running - running or paused containers cannot be removed without force: container state improper
```

What's happening? This does not work. In order to be able to delete the container, we need to stop it first:
```
podman stop mynginx
```
```
mynginx
```
```
podman rm mynginx
```
```
097ee94c96e5e6e1655ed688fbe043a14d769248bf907effc64bc740f8acfe49
```

This time it worked. 

Now we'll run a new container from the same image, this time performing a port forwarding of a port on our host machine to a port in the container:
```
podman run -d --name mynginx -p 8081:8080 quay.io/rhettibm/nginx
```
_NOTE: in order to avoid port conflicts, please use as the local port (the one on the left of the ':') your user number + 8000. For example, user 1 will use 8001._

What did we just do? We told podman to forward traffic on the host port 8081 to the container port 8080. 

We can try that is working by connecting to port 8081 on the host:
```
curl localhost:8081
```
```
...
<title>Welcome to nginx!</title>
...
```
With this we see that our nginx web server is working as expected.

A little bit of housekeeping: remove the nginx image and container:
```
podman stop mynginx
```
```
mynginx
```
```
podman rm mynginx
```
```
0718b4a9411235a561d0d2a8dfab78750c91f7c2094b58521a0bd4963c24398a
```
```
podman rmi quay.io/rhettibm/nginx
```
```
Untagged: docker.io/bitnami/nginx:latest
Deleted: 55027d4388b7e10014c9983093a10bdd08e7272aabbb15e2919866d9bdc49e80
```

### MariaDB

_MariaDB is an open-source database server based on MySQL_

We want to create a new container from a MariaDB image:
```
podman run --name mymariadb -d -p 3307:3306 quay.io/rhettibm/mariadb
```
```
✔ docker.io/bitnami/mariadb:latest
Trying to pull docker.io/bitnami/mariadb:latest...
```
_NOTE: in order to avoid port conflicts, please use as the local port (the one on the left of the ':') your user number + 3306. For example, user 1 will use 3307._

When we list the locally available images, we see a mariadb image on the list:
```
podman images
```
```
REPOSITORY                 TAG         IMAGE ID      CREATED       SIZE
docker.io/bitnami/mariadb  latest      179e8d2f6d89  12 hours ago  338 MB
```
However, if we list the running containers with _podman ps_, we'll see there is no mariadb container there.

To be able to see also the stopped and exited containers, we use another command:
```
podman ps -a
```
```
CONTAINER ID  IMAGE                             COMMAND               CREATED             STATUS                         PORTS                    NAMES
c8e968144f86  docker.io/bitnami/mariadb:latest  /opt/bitnami/scri...  About a minute ago  Exited (1) About a minute ago  0.0.0.0:3306->3306/tcp  mymariadb
```

What happened? The container is not running. To take a look at what the problem might be, we'll inspect the logs:
```
podman logs c8e968144f86
```
```
...
mariadb 10:02:59.48 Welcome to the Bitnami mariadb container
...
mariadb 10:02:59.51 ERROR ==> The MARIADB_ROOT_PASSWORD environment variable is empty or not set. Set the environment variable ALLOW_EMPTY_PASSWORD=yes to allow the container to be started with blank passwords. This is recommended only for development.
```

That is the reason of the failure. At least the environment variable MARIADB_ROOT_PASSWORD must be set so the container can start. How do we set the value of environment variables for a container? We can pass them as arguments in the _podman run_ command. 

Since we want to reuse the same container name _mymariadb_ we need to remove the failed one first:
```
podman rm mymariadb
```
```
c8e968144f861cfba12c8d1238029a6ffe129be1fe90181f15a6838e771b4565
```

Then we run a new container from the same image, this time providing the required environment variable:
```
podman run -d --name mymariadb -p 3307:3306 -e MARIADB_ROOT_PASSWORD=passw0rd rhettibm/mariadb
```
```
de035cd79b5461ec102d7cb2fa7c47672a8585e5a71a44796741ab5ae618c984
```

This time the container did not exit, we see it's up and running:
```
podman ps
```
```
CONTAINER ID  IMAGE                             COMMAND               CREATED         STATUS             PORTS                    NAMES
de035cd79b54  docker.io/bitnami/mariadb:latest  /opt/bitnami/scri...  1 second ago    Up 1 second ago    0.0.0.0:3306->3306/tcp  mymariadb
```

That means our database server is running. There is a way to connect to a running container, that's what we are trying next:
```
podman exec -it mymariadb /bin/bash
```
```
1001@de035cd79b54:/$ 
```

What does this mean?
 * The _exec_ command tells podman to execute a command on the running container
 * The _-it_ parameter tells to execute the command interactively and to attach a terminal, so we can interact
 * The _/bin/bash_ is the command to be ran

Inside the MariaDB container, we can for example connect to the database:
```
1001@de035cd79b54:/$ mysql -uroot -ppassw0rd

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.6.5-MariaDB Source distribution
```

Exit the mysql shell and then the running container:
```
MariaDB [(none)]> exit
Bye

1001@de035cd79b54:/$ exit
exit

user1:~$ 
```

Clean-up everything:
```
podman stop --all
```
```
podman rm --all
```
```
podman rmi --all
```

Congratulations! You finished your first lab :)
