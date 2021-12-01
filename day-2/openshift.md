## Working with OpenShift

After you learnt about containers, images and podman, in this lab you are going to work with OpenShift. 

### Table of contents

1. Command line interface
2. Create a new project
3. Create an application from an existing image
4. Add a route

_Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services._

_OpenShift is a Kubernetes distribution._

### 1. Command Line Interface

The OpenShift cluster was already provisioned for you. Log in using the _oc_ command line tool:
```
user1:~$ oc login --token=$TOKEN --server=$URL
```
_NOTE: the environment variables TOKEN and URL must have been set._

Let's explore the CLI help a little bit:
```
user1:~$ oc --help

OpenShift Client

This client helps you develop, build, deploy, and run your applications on any
OpenShift or Kubernetes cluster. It also includes the administrative
commands for managing a cluster under the 'adm' subcommand.
```

### 2. Create a new project

_In Kubernetes, a Namespace provices a mechanism to scope resources in a cluster. In OpenShift, a Project is a Kubernetes Namespace with additional annotations._

In OpenShift, all resources are grouped into projects.

__Demonstration__: create a project using the OpenShift web console

_The teacher might show first how to create a project on the web console._

__Exercise__: create your project using the oc CLI

Create your namespace/project:
```
user1:~$ oc new-project user1

Now using project "user1" on server "https://c115-e.eu-de.containers.cloud.ibm.com:32297".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname
```
_NOTE: Replace the 1 with your user number_


List all available projects:
```
user1:~$ oc projects
```
The project you just created has a * next to its name. That means that's the current project in use.

### 3. Create a new application from an existing image

Now you have your own namespace/project, deploy your first application on OpenShift. 

There are three ways to create a new application in OpenShift:

 * From an image
 * From source code
 * From a template

In this lab, we are going to explore the first one, building an application from an existing image. 

__Demonstration__: how to create an application using the OpenShift Web Console

_The teacher might show first how to create an application from an image on the web console._

__Exercise__: create your application using the CLI

In the first two labs - containers, images, podman and custom images - we used images from the public registry dockerhub. In this lab, we are going to use an image from a RedHat registry.

Let's see how the command looks like:
```
user1:~$ oc new-app --name myhttpd registry.access.redhat.com/rhscl/httpd-24-rhel7

--> Found container image a8d6d7d (11 days old) from registry.access.redhat.com for "registry.access.redhat.com/rhscl/httpd-24-rhel7"

    Apache httpd 2.4 
    ---------------- 
    Apache httpd 2.4 available as container, is a powerful, efficient, and extensible web server. Apache supports a variety of features, many implemented as compiled modules which extend the core functionality. These can range from server-side programming language support to authentication schemes. Virtual hosting allows one Apache installation to serve many different Web sites.

    Tags: builder, httpd, httpd24

    * An image stream tag will be created as "myhttpd:latest" that will track this image

--> Creating resources ...
    imagestream.image.openshift.io "myhttpd" created
    deployment.apps "myhttpd" created
    service "myhttpd" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/myhttpd' 
    Run 'oc status' to view your app.
```

It's actually quite simple:
 * The _oc new-app_ create a new application on the current project
 * The _--name_ parameter gives a name to the new application
 * The last parameter is the container image, in the form _registry/image_

Let's see what happened:
```
user1:~$ oc get all

NAME                          READY   STATUS    RESTARTS   AGE
pod/myhttpd-c95cb9dd7-zdznk   1/1     Running   0          37s

NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/myhttpd   ClusterIP   172.21.197.158   <none>        8080/TCP,8443/TCP   38s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myhttpd   1/1     1            1           38s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/myhttpd-758c858d48   0         0         0       38s
replicaset.apps/myhttpd-c95cb9dd7    1         1         1       37s
...
```
Following resources have been created:

 * A deployment
 * The pods, which host the instances of the application 
 * A replica set, as part of the deployment, which manages the pods to be ran
 * A service, so the pods are accessible regardless of their IP address

_A Deployment manages the Pods and ReplicaSets._

_A Pod is one or more containers deployed on a host_

_A Service serves as an internal load balancer. It identifies a set of replicated pods in order to proxy the connections it receives to them._

If we want to see the details of the deployment, we can do it like this:
```
user1:~$ oc describe deployment myhttpd
```

Or alternatively, we can see the declarative form of the deployment in yaml format:
```
user1:~$ oc get deployment myhttpd -o yaml
```

We can find among other information:
- The docker image used: _registry.access.redhat.com/rhscl/httpd-24-rhel7_ 
- The number of replicas: in this example 1

### 4. Add a route

_An openshift route is a way to expose a service by giving it an externally accessible hostname_

In order to make our new apache server accessible from outside the cluster, we need to create a route.

__Demonstration__: show how to create a route using the OpenShift web interface

_The teacher might show first how to create a route on the web console._

__Exercise:__ create the route using the CLI

Create the route exposing the service:
```
user1:~$ oc expose service myhttpd

route.route.openshift.io/myhttpd exposed
```

Find out the URL to access the service externally:
```
user1:~$ oc describe route myhttpd
```
In the output, you'll find the host name indicated by _Request Host_. Put it in an environment variable:
```
user1:~$ export HOST=<write here the URL you got>
```

Test that it's working, issuing a curl command:
```
user1:~$ curl $HOST:8080 
```

Did you get the HTML code of the index page of Apache? If so, congratulations, you deployed an Apache Web Server on OpenShift :)

