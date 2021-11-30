## Deploy an application from source code

We mentioned in the previous lab that there is three ways to create an application with _oc new-app_. In this lab, we are going to explore how to deploy an application directly from source code. 

_One of the main differences between OpenShift and Kubernetes is the concept of build-related artifacts. In OpenShift, such artififacts are considered first class Kubernetes resources upon which standard Kubernetes operators can apply._

OpenShift relies internally on _Source-to-Image (S2I)_ to build reproducible, Docker-formatted container images. 

 * 1. Demonstration: create application from source on the WebConsole (Optional)
 * 2. Exercise: create application from source on the command line

For this exercise, we have prepared a simple nodejs application, which you can find on the labs github:
https://github.com/IBM/csm-dach-cloud-native-labs/nodejs-helloworld

Let's try it out:
```
eramon:~$ oc new-app https://github.com/IBM/csm-dach-cloud-native-labs#workshop --name helloworld --context-dir=nodejs-helloworld
--> Found image e7672e7 (3 weeks old) in image stream "openshift/nodejs" under tag "14-ubi8" for "nodejs"

    Node.js 14 
    ---------- 
    Node.js 14 available as container is a base platform for building and running various Node.js 14 applications and frameworks. Node.js is a platform built on Chrome's JavaScript runtime for easily building fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

    Tags: builder, nodejs, nodejs14

    * The source repository appears to match: nodejs
    * A source build using source code from https://github.com/IBM/csm-dach-cloud-native-labs will be created
      * The resulting image will be pushed to image stream tag "helloworld:latest"
      * Use 'oc start-build' to trigger a new build

--> Creating resources ...
    imagestream.image.openshift.io "helloworld" created
    buildconfig.build.openshift.io "helloworld" created
    deployment.apps "helloworld" created
    service "helloworld" created
--> Success
    Build scheduled, use 'oc logs -f buildconfig/helloworld' to track its progress.
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/helloworld' 
    Run 'oc status' to view your app.
```

Let's examine the resource which were created:
```
eramon:~$ oc get all
NAME                              READY   STATUS      RESTARTS   AGE
pod/helloworld-1-build            0/1     Completed   0          88s
pod/helloworld-768796c5b8-pll66   1/1     Running     0          37s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/helloworld   ClusterIP   172.21.104.33   <none>        8080/TCP   12m

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld   1/1     1            1           12m

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-768796c5b8   1         1         1       37s

NAME                                        TYPE     FROM   LATEST
buildconfig.build.openshift.io/helloworld   Source   Git    4

NAME                                    TYPE     FROM          STATUS                        STARTED              DURATION
build.build.openshift.io/helloworld-1   Source   Git@bc703d5   Complete                      About a minute ago   52s

NAME                                        IMAGE REPOSITORY                                                    TAGS     UPDATED
imagestream.image.openshift.io/helloworld   image-registry.openshift-image-registry.svc:5000/user1/helloworld   latest   37 seconds ago
```

When creating an application from source, resources are automatically generated:

 * The Pods which host the application 
 * A Deployment: we see the deployment "helloworld"
 * A ReplicaSet: as part of the deployment, the replicaset "helloworld" aims to create 1 replica
 * A Service: the service "helloworld" allows the internal access to the application
 * A BuildConfig: the build config created the build container which took care of building the application
 * An ImageStream: the imagestream "helloworld" represents the different versions of the created images

_A build is the process of transforming input parameters into a resulting object. Most often, the process is used to transform input parameters or source code into a runnable image. A BuildConfig object is the definition of the entire build process._

_An image stream and its associated tags provide an abstraction for referencing container images. The image stream and its tags allow to see what images are available and ensure you are using the specific image you need even if the image in the repository changes_

We see, a build container was created, which took care of building the application. Upon termination, the application pods were created and are running. 

The service allows to access the application internally, but if we want to access it externally? We need to create a route.

_A route exposes a service at a host name_ 

To create a route we need to expose the service associated with the application. 
Let's create a route:
```
eramon:~$ oc expose service/helloworld
route.route.openshift.io/helloworld exposed
```

Examine the details of the route resource:
```
eramon:~$ oc describe route helloworld
Name:			helloworld
Namespace:		user1
Created:		25 seconds ago
Labels:			app=helloworld
			app.kubernetes.io/component=helloworld
			app.kubernetes.io/instance=helloworld
Annotations:		openshift.io/host.generated=true
Requested Host:		helloworld-user1.externaldemo-5115c94768819e85b5dd426c66340439-0000.eu-de.containers.appdomain.cloud
			   exposed on router default (host externaldemo-5115c94768819e85b5dd426c66340439-0000.eu-de.containers.appdomain.cloud) 25 seconds ago
Path:			<none>
TLS Termination:	<none>
Insecure Policy:	<none>
Endpoint Port:		8080-tcp

Service:	helloworld
Weight:		100 (100%)
Endpoints:	172.30.157.17:8080
```

We see the hostname which was assigned to the route. Let's try it:
```
eramon:~$ curl helloworld-user1.externaldemo-5115c94768819e85b5dd426c66340439-0000.eu-de.containers.appdomain.cloud
Hello World!
```

Our helloworld application is greeting us from inside the pod, deployed in our OpenShift cluster :D

__Demonstration:__ What if we change something in the application? Let's see how to manage changes. 

Change the text in _app.js_ to say "Hello OpenShift!" instead of "Hello World!"
```
eramon:csm-dach-cloud-native-labs$ cd nodejs-helloworld/
eramon:nodejs-helloworld$ sed -i 's/World/Openshift/g' app.js
```

Commit and push the changes:
```
eramon:nodejs-helloworld$ git add app.js
eramon:nodejs-helloworld$ git commit -m "Change hello message"
eramon:nodejs-helloworld$ git push
```

 5) Restart the build with _oc start build helloworld_

```
eramon:nodejs-helloworld$ oc start-build helloworld
build.build.openshift.io/helloworld-2 started
```

If we inspect the resources with _oc get all_, we'll see:

 * There is a new builder pod _helloworld-2-build_, which after a short while should be in stautus _Completed_
 * A new build config _helloworld-2_, which after the build should be in status _Complete_
 * The previously running pod terminate
 * A new pod running the modified application

If we test the same url as before, we should see the new message:
```
eramon:nodejs-helloworld$ curl helloworld-user1.externaldemo-5115c94768819e85b5dd426c66340439-0000.eu-de.containers.appdomain.cloud
Hello Openshift! 
```

## References:

_The application example is the one available here:
https://github.com/RedHatTraining/DO180-apps_
