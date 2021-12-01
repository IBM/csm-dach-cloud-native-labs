## Deploying an application in a declarative way 

### Table of contents

1. Namespace
2. Secret
3. Deployment
4. Service
5. Create the resources
6. Log in to the database server 

We saw how to deploy applications in openshift. We did this in an imperative way, issuing the oc commands which tell the openshift cluster - via API calls - which is the new desired state of the cluster i.e. which operations must be performed. 

In this lab we are going to see how to do this in a declarative way: writting yaml files which define the desired state of the cluster, then just applying them to generate the openshift resources.

The application to be deployed is going to be MariaDB. 

The sample yaml files are available in this repository.

### 1. Namespace

The namespace (project):
```
apiVersion: v1
kind: Namespace
metadata:
  name: lab6 
```
[lab6-namespace.yaml](yaml/lab6-namespace.yaml)

For the upcoming yaml files, it's important to specify the namespace to be _lab6_ so all resources are created in the same project.

In this lab we are going to use a secret to save the root password for MariaDB.

### 2. Secret

The secret:
```
apiVersion: v1
kind: Secret
metadata:
  name: mariadb-secret
  namespace: lab6
type: Opaque
data:
  password: cGFzc3cwcmQ=
```
[mariadb-secret.yaml](yaml/mariadb-secret.yaml)

The secret saves the root password for MARIADB. The value of the secret is the string "passw0rd" base64-encoded.

In the deployment, the secret containing the root password must be specified as environment variable.

### 3. Deployment

The deployment:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: lab6
spec:
  replicas: 1
  selector:
    matchLabels:
      deployment: mariadb
  template:
    metadata:
      labels:
        deployment: mariadb
    spec:
      containers:
      - image: docker.io/bitnami/mariadb
        name: mariadb
        ports:
        - containerPort: 3306
          protocol: TCP
        env:
        - name: MARIADB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mariadb-secret
              key: password
```
[mariadb-deplyoment.yaml](yaml/mariadb-deployment.yaml)

We are using the same image we used on day 1 to practice with podman. 

### 4. Service

The service, to access the application internally:
```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mariadb
  name: mariadb
  namespace: lab6
spec:
  ports:
  - name: 3306-tcp
    port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    deployment: mariadb
  type: ClusterIP
```
[mariadb-service.yaml](yaml/mariadb-service.yaml)

The service uses selectors (labels) to know which pods to connect to when the service is accessed.

### 5. Create the resources

All we need is now declared in the yaml files. To deploy the database, we just have to apply the yaml files to generate the resources:
```
user1:~$ oc apply -f yaml 

namespace/lab6 created
deployment.apps/mariadb created
secret/mariadb-secret created
service/mariadb created
```

Let's change to the new created project and see if the resources are there:
```
user1$ oc project lab6
Now using project "lab6" on server "https://c115-e.eu-de.containers.cloud.ibm.com:32297".

user1:~$ oc get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/mariadb-58c7665fd5-mb44w   1/1     Running   0          100s

NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/mariadb   ClusterIP   172.21.240.129   <none>        3306/TCP   101s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mariadb   1/1     1            1           101s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/mariadb-58c7665fd5   1         1         1       101s
```

Everything is looking good. The namespace, the deployment (and therefore the pods and the replicaset), the secret and the service were created. The pod - we specified only 1 replica - is running.

### 6. Log in to the database server 

To check that our database is running, let's connect to the running container:
```
user1:~$ oc exec -it mariadb-58c7665fd5-mb44w -- /bin/bash

1000670000@mariadb-58c7665fd5-mb44w:/$ mysql -uroot -ppassw0rd
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.6.5-MariaDB Source distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

It's working :) Our database is running and the root password is the one stored in the secret.

To exit the mysql and the running container, type _exit_ twice.

Congratulations! You finished the last lab.

