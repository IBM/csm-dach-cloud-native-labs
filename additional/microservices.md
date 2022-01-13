## An introduction to microservices 

This exercise features two different applications deployed in OpenShift which interact with each other as components of a bigger application. 

_A microservice architecture structural style arranges an application as a collection of loosely-coupled services. In a microservices architecture, services are fine-grained and the protocols are lightweight._

### Table of contents

1. Database 
2. Wordpress 

### 1. Database 

Let's start deploying a MySQL database from an image:
```
eramon:~$ oc new-app --name mysql --docker-image bitnami/mysql
```
If we take a look at the pods, we'll see the pod is not starting:
```
eramon:~$ oc get pods
NAME                     READY   STATUS             RESTARTS   AGE
mysql-7449f75c5d-czqqx   0/1     CrashLoopBackOff   2          66s
```
What's the problem? Let's take a look at the logs:
```
mysql 12:43:30.62 ERROR ==> The MYSQL_ROOT_PASSWORD environment variable is empty or not set. Set the environment variable ALLOW_EMPTY_PASSWORD=yes to allow the container to be started with blank passwords. This is recommended only for development.
```
As it looks, we need to set the MYSQL_ROOT_PASSWORD variable. 

For this, we are going to use a Kubernetes resource called _secret_.

_A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code._

Let's create the secret from a literal value, setting _password_ as the root password:
```
eramon:~$ oc create secret generic mysql-secret --from-literal=password=password
```

Now, we need to tell the _deployment_ to use the value defined by our _secret_ as an environment variable:
```
eramon:~$ oc set env deployment/mysql --from=secret/mysql-secret --prefix=MYSQL_ROOT_
```
How did we do that? Well, we said we want to set an environment variable in the deployment _mysql_ from the secret _mysql-secret_ using a prefix, which means the environment variable will be called MYSQL_ROOT_PASSWORD and its value will be _password_.

Now we'll see the pod is indeed starting:
```
eramon:~$ oc get pods
NAME                     READY   STATUS    RESTARTS   AGE
mysql-5c65d7dcf6-6bx77   1/1     Running   0          2m12s
```

Now we have our mysql deployment, next thing to do is to deploy an application _wordpress_ which will use this mysql server instance as its database.

### 2. Wordpress

_WordPress is a free and open-source content management system (CMS) written in PHP and paired with a MySQL or MariaDB database._

Let's create a new application from an existing image:
```
eramon:~$ oc new-app --name wordpress --docker-image bitnami/wordpress
```
This is not going to work yet, since the wordpress application needs a bunch of environment variables to be set in order to work properly. 

For the mysql instance we used a secret, because what we were storing inside was a password. This time we'll use another K8s resource called _configmap_.

_A ConfigMap is an object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume. It allows you to decouple environment-specific configuration from your container images, so that your applications are easily portable._

Let's create the configmap:
```
eramon$ oc create configmap wordpress-config --from-literal=host=mysql --from-literal=port_number=3306 --from-literal=user=wordpress --from-literal=name=wordpress
```
Important in this list of key-pair values is to see who both applications are bound to each other. The wordpress applications uses _mysql_ as database host. _mysql_ is the name of the mysql application which is running, which also corresponds to the hostname of the pod. The string _mysql_ resolvs to the pod hosting the mysql server.

Now let's set the configmap as environment variables:
```
eramon$ oc set env deployment/wordpress --from=configmap/wordpress-configmap --prefix=WORDPRESS_DATABASE_
```
The prefix indicates that the variables will be in the form WORDPRESS_DATABASE_HOST, for example.  

In addition to the environment variables we just set, wordpress needs a password, stored in the environment variable WORDPRESS_DATABASE_PASSWORD. For this, we'll use the same password as for the mysql application before, that means we can use the same secret:
```
eramon$ oc set env deployment/wordpress --from=secret/mysql-secret --prefix=WORDPRESS_DATABASE_
```
Let's go inside the wordpress running container and take a look at the environment variables:
```
eramon$ oc exec -it wordpress-5b9dfb44d-x2m8r -- /bin/bash
1001@wordpress-5b9dfb44d-x2m8r:/$ env |grep WORDPRESS_DATABASE_
WORDPRESS_DATABASE_HOST=mysql
WORDPRESS_DATABASE_USER=wordpress
WORDPRESS_DATABASE_PORT_NUMBER=3306
WORDPRESS_DATABASE_NAME=wordpress
WORDPRESS_DATABASE_PASSWORD=password
```

_TODO: not working_
