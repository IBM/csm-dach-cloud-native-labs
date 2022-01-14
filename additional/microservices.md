## An introduction to microservices 

This exercise features two different applications deployed in OpenShift which interact with each other as components of a bigger application. 

_A microservice architecture structural style arranges an application as a collection of loosely-coupled services. In a microservices architecture, services are fine-grained and the protocols are lightweight._

### Table of contents

1. Database 
2. Wordpress 

### 1. Database 

Let's start deploying a MariaDB database from an image:
```
user1:~$ oc new-app --name mariadb --docker-image bitnami/mariadb
```
If we take a look at the pods, we'll see the pod is not starting:
```
user1$ oc get pods
NAME                        READY   STATUS             RESTARTS   AGE
mariadb-bd54cc664-4hr6t     0/1     Error              0          17s
```
What's the problem? Let's take a look at the logs:
```
mariadb 07:59:34.54 ERROR ==> The MARIADB_ROOT_PASSWORD environment variable is empty or not set. Set the environment variable ALLOW_EMPTY_PASSWORD=yes to allow the container to be started with blank passwords. This is recommended only for development.
```
As it looks, we need to set at least the MARIADB_ROOT_PASSWORD variable. 

For this, we are going to use a Kubernetes resource called _secret_.

_A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code._

Let's create the secret from a literal value, setting _password_ as the root password:
```
user1:~$ oc create secret generic mariadb-secret --from-literal=password=password
```

Now, we need to tell the _deployment_ to use the value defined by our _secret_ as an environment variable:
```
user1:~$ oc set env deployment/mariadb --from=secret/mariadb-secret --prefix=MARIADB_ROOT_
```
How did we do that? Well, we said we want to set an environment variable in the deployment _mariadb_ from the secret _mariadb-secret_ using a prefix, which means the environment variable will be called MARIADB_ROOT_PASSWORD and its value will be _password_.

But the pod is still not starting. Let's check the logs:
```
mariadb 08:10:51.33 ERROR ==> The MARIADB_PASSWORD environment variable is empty or not set. Set the environment variable ALLOW_EMPTY_PASSWORD=yes to allow the container to be started with blank passwords. This is recommended only for development.
```
Oh, we need to set the MARIADB_PASSWORD as well. We can use the same password, how convenient :)  So we'll use the same secret with another prefix to set the variable:
```
user1$ oc set env deployment/mariadb --from=secret/mariadb-secret --prefix=MARIADB_
```
If we list the running pods again, now we'll see the pod started correctly.

In addition to the root password, there are two additional environment variables we need to set: MARIADB_USER and MARIADB_DATABASE.

For the passwords we used a secret. This time we'll use another K8s resource called _configmap_.

_A ConfigMap is an object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume. It allows you to decouple environment-specific configuration from your container images, so that your applications are easily portable._

Let's create the configmap:
```
user1$ oc create configmap mariadb-config --from-literal=user=bn_wordpress --from-literal=database=bitnami_wordpress
```

And now let's mount it, in the same way we did before with the secret:
```
oc set env deployment/mariadb --from=configmap/mariadb-config --prefix=MARIADB_
```

Let's go inside the running container and take a look to make sure all environment variables are indeed there:
```
user1$ oc get pods
NAME                         READY   STATUS    RESTARTS   AGE
mariadb-7c64cff894-pzl7s     1/1     Running   0          20m
wordpress-759c4dfd96-9cnfm   1/1     Running   0          10m
user1$ oc exec -it mariadb-7c64cff894-pzl7s -- /bin/bash
1001@mariadb-7c64cff894-pzl7s:/$ env |grep MARIADB_
...
MARIADB_USER=bn_wordpress
MARIADB_DATABASE=bitnami_wordpress
...
MARIADB_ROOT_PASSWORD=password
MARIADB_PASSWORD=password
...
```
That looks good so far. Exit the running container typing _exit_.

Now we have our database deployment, next thing to do is to deploy an application _wordpress_ which will use this mariadb server instance as its database.

### 2. Wordpress

_WordPress is a free and open-source content management system (CMS) written in PHP and paired with a MySQL or MariaDB database._

Let's create a new application from an existing image:
```
user1:~$ oc new-app --name wordpress --docker-image bitnami/wordpress
```
This is not going to work yet, since the wordpress application needs a bunch of environment variables to be set in order to work properly. 

So let's create a new configmap:
```
user1$ oc create configmap wordpress-config --from-literal=host=mariadb --from-literal=port_number=3306 --from-literal=user=bn_wordpress --from-literal=name=bitnami_wordpress
```
Important to notice here are following values:
 * The _host_ points to the mariadb deployment, using _mariadb_ as database host. This is the name of the pods which matches the DNS name inside the pod network, so the wordpress deployment will be able to resolve this hostname to the IP of the mariadb application
 * The _user_ matches the MARIADB_USER set in the mariadb deployment before
 * The _name_ matches the MARIADB_DATABASE set in the mariadb deployment before

Let's set the configmap as we did before:
```
user1$ oc set env deployment/wordpress --from=configmap/wordpress-config --prefix=WORDPRESS_DATABASE_
```

The prefix indicates that the variables will be in the form WORDPRESS_DATABASE_xyz, for example WORDPRESS_DATABASE_HOST.

In addition to the environment variables we just set, wordpress needs a password, stored in the environment variable WORDPRESS_DATABASE_PASSWORD. For this, we'll use the same password as for the mysql application before, that means we can use the same secret:
```
user1$ oc set env deployment/wordpress --from=secret/mariadb-secret --prefix=WORDPRESS_DATABASE
```
Let's go inside the wordpress running container and take a look at the environment variables:
```
user1$ oc exec -it wordpress-5b9dfb44d-x2m8r -- /bin/bash
1001@wordpress-759c4dfd96-9cnfm:/$ env |grep WORDPRESS_DATABASE_
WORDPRESS_DATABASE_HOST=mariadb
WORDPRESS_DATABASE_USER=bn_wordpress
WORDPRESS_DATABASE_PORT_NUMBER=3306
WORDPRESS_DATABASE_NAME=bitnami_wordpress
WORDPRESS_DATABASE_PASSWORD=password
```
That's looking good, all needed variables are there. Exit the running container typing _exit_.

Before we try out the application, we need to create a route to expose the service to external connections - same as we did in previous exercises:
```
user1$ oc expose service/wordpress
```
To get the URL, we describe the route we just created:
```
user1$ oc describe route wordpress
Name:			wordpress
Namespace:		default
Created:		3 minutes ago
Labels:			app=wordpress
			app.kubernetes.io/component=wordpress
			app.kubernetes.io/instance=wordpress
Annotations:		openshift.io/host.generated=true
Requested Host:		wordpress-default.itzroks-6620021ddi-mjkann-6ccd7f378ae819553d37d5f2ee142bd6-0000.ams03.containers.appdomain.cloud
			   exposed on router default (host itzroks-6620021ddi-mjkann-6ccd7f378ae819553d37d5f2ee142bd6-0000.ams03.containers.appdomain.cloud) 3 minutes ago
Path:			<none>
TLS Termination:	<none>
Insecure Policy:	<none>
Endpoint Port:		8080-tcp

Service:	wordpress
Weight:		100 (100%)
Endpoints:	172.30.62.240:8080, 172.30.62.240:8443
```
To try the application, open the URL you see under _Requested Host_ on your browser. You'll see something like that:
![Alt text](helloworld.png?raw=true "Wordpress")

And that's it :) Even if this is a very simple example, you see how - abiding to the microservices best practices  - two applications which are independent from one another can be loosely coupled through the environment variables. 


