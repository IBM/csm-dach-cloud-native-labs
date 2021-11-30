## Working with OpenShift 4.x

After you learnt about containers, images and podman, in this lab you are going to work with OpenShift. 

### Table of contents

1. Command line interface
2. Create a new project
3. Create an application from an existing image
4. Add a route

_Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services._

_OpenShift_ is a Kubernetes distribution (...)

### 1. Command Line Interface

The OpenShift cluster was already provisioned for you. Log in using the _oc_ command line tool:
```
eramon:~$ oc login --token=$TOKEN --server=$URL
```

Let's explore the CLI help a little bit:
```
eramon:~$ oc --help
OpenShift Client

This client helps you develop, build, deploy, and run your applications on any
OpenShift or Kubernetes cluster. It also includes the administrative
commands for managing a cluster under the 'adm' subcommand.
```

### 2. Create a new project

_In Kubernetes, a Namespace provices a mechanism to scope resources in a cluster.In OpenShift, a Project is a Kubernetes Namespace with additional annotations._

In OpenShift, all resources are grouped into projects.

__Demonstration__: create a project using the OpenShift web console

__Exercise__: create your project using the oc CLI

Create your project 
```
eramon:~$ oc new-project user1
Now using project "user1" on server "https://c115-e.eu-de.containers.cloud.ibm.com:32297".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app rails-postgresql-example

to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

    kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname
```
_NOTE: Replace the 1 with your user number_


List all available projects:
```
eramon:~$ oc projects
```
The project you just created has a * next to its name. That means that's the current project in use.

### 3. Create a new application from an existing image

Now you have your own namespace/project, deploy your first application on OpenShift. 
There are three ways to create a new application in OpenShift:

 * From an image
 * From source code
 * From a template

In this lab, we are going to explore the first one, building an application from an existing image. 

__Demonstration__: how to create an application from the OpenShift Web Console

__Exercise__: create your application using the CLI

In this lab, we are going to use an image from the RedHat registry. 

In the first lab featuring podman, we used images from the public registry dockerhub. The featured image in this lab is registry.redhat.io/rhscl/httpd-24-rhel7, which is a HTTP 2.4 Server.

Let's see how the command looks like:
```
eramon:~$ oc new-app --name myapache registry.redhat.io/rhscl/httpd-24-rhel7
--> Found container image a8d6d7d (11 days old) from registry.redhat.io for "registry.redhat.io/rhscl/httpd-24-rhel7"

    Apache httpd 2.4 
    ---------------- 
    Apache httpd 2.4 available as container, is a powerful, efficient, and extensible web server. Apache supports a variety of features, many implemented as compiled modules which extend the core functionality. These can range from server-side programming language support to authentication schemes. Virtual hosting allows one Apache installation to serve many different Web sites.
...
```

It's actually quite simple:
 * The _oc new-app_ create a new application on the current project
 * The _--name_ parameter gives a name to the new application
 * The last parameter is the container image, in the form _registry/image_

Let's see what happened:
```
eramon:~$ oc get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/myapache-d44679678-vt684   1/1     Running   0          9m21s
pod/myhttpd-7b57d6978d-ntwzf   1/1     Running   0          37s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/myapache   ClusterIP   172.30.147.242   <none>        8080/TCP,8443/TCP   9m21s
service/myhttpd    ClusterIP   172.30.20.237    <none>        8080/TCP,8443/TCP   39s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myapache   1/1     1            1           9m22s
deployment.apps/myhttpd    1/1     1            1           39s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/myapache-595cfc959b   0         0         0       9m22s
replicaset.apps/myapache-d44679678    1         1         1       9m22s
replicaset.apps/myhttpd-758c858d48    0         0         0       39s
replicaset.apps/myhttpd-7b57d6978d    1         1         1       38s
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
eramon:~$ oc describe deployment myapache
```

Or alternatively, we can see the declarative form of the deployment in yaml format:
```
eramon:~$ oc get deployment -o yaml
```

We can find among other information:
- The docker image used: registry.redhat.io/rhscl/httpd-24-rhel7
- The number of replicas: in this example 1

### 4. Add a route

_An openshift route is a way to expose a service by giving it an externally accessible hostname_

In order to make our new apache server accessible from outside the cluster, we need to create a route.

__Demonstration__: show how to create a root on the Web Interface

__Exercise:__ create the route using the CLI

Create the route exposing the service:
```
eramon:~$ oc expose svc/myapache
route.route.openshift.io/myapache exposed
```

Find out the URL to access the service externally:
```
eramon:~$ oc describe route myapache
Name:			myapache
Namespace:		eva-ramon-ibm-dev
Created:		20 seconds ago
Labels:			app=myapache
			app.kubernetes.io/component=myapache
			app.kubernetes.io/instance=myapache
Annotations:		openshift.io/host.generated=true
Requested Host:		myapache-eva-ramon-ibm-dev.apps.sandbox.x8i5.p1.openshiftapps.com
			   exposed on router default (host router-default.apps.sandbox.x8i5.p1.openshiftapps.com) 20 seconds ago
Path:			<none>
TLS Termination:	<none>
Insecure Policy:	<none>
Endpoint Port:		8080-tcp

Service:	myapache
Weight:		100 (100%)
Endpoints:	10.129.2.19:8080, 10.129.2.19:8443
```

Test that it's working, issuing a curl command to the host indicated by _Requested Host_ in the output above:
```
eramon:~$ curl myapache-eva-ramon-ibm-dev.apps.sandbox.x8i5.p1.openshiftapps.com
```

Did you get the HTML code of the index page of Apache? If so, congratulations, you deployed an Apache Web Server on OpenShift :)

