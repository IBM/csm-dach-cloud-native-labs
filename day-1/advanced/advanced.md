## Create advanced container images

In this lab we are going to see some best practices to build more advanced container images:

- Reference a base image by its unique digest
- Introduce multi-stage builds to shrink the final container image's size
- Introduce new instructions such as: WORKDIR, COPY, ENV, ARG and USER

The following example shows an andvanced Containerfile.

Before we go through it step by step, let me quickly introduce a new concept, which is called **multi-stage builds**. The goal is to keep the final image as small as possible.

If we use a typical Node.js base image, it comes with tools such as the Node Package Manager (npm) and more. This is necessary to build your application, but you won't need npm to run your app.

What we can do is to split the image build in multiple stages and use different base images for each stage.

- In the first stage (build) we use a heavy base image, containing npm and more. We also reference this image with an alias called "builder".
- In the second stage (run) we then take a much slimmer base image, which only contains the Node.js runtime and copy the previously installed depencendies over.

This results in a final image size, that is roughly 8 times smaller!

```
# BUILD STAGE

# Node.js 16.13.1
FROM node@sha256:534004248435dea5cecf3667232f800fc6bd101768306aecf6b87d78067b0563 as builder
# By using the digest (@sha...) we uniquely and immutably identify a container image. Tags such as v1.0 are only pointers to a specific image. The digest is a more precise way to identify an image. The alias "builder" we set will become relevant in the next stage.

WORKDIR /app
# The WORKDIR instruction creates a folder inside the container and defines it as the working directory for all subsequent instructions.

COPY ["app.js", "package.json", "/app/"]
# The COPY instruction copies files from the host into the container image. The array's last index must be the destination inside the container
# You could also use the ADD instruction instead. The ADD instruction even extracts archives (apart from *.zip) while copying.

RUN npm install


# RUN STAGE

# Node.js 16.13.1-alpine3.14
FROM node@sha256:8569c8f07454ec42501e5e40a680e49d3f9aabab91a6c149e309bac63a3c8d54
# For the final container image we take a much smaller base image (~113MB) and copy the installed depencendies from the build stage. This is called a multi-stage build.

WORKDIR /app

COPY --from=builder /app/ .

LABEL author="Raphael Tholl raphael.tholl@ibm.com"

ENV username=raphael
# The ENV instruction sets an environment variable, which the app can later access.
# The ARG instruction is rather similar. The difference is that ARG variables are only accessible during the image build process.

RUN chown -R node:node /app
# It is considered best practice to not run your applications as root inside the container. Thus, we use the node user, which is provided by the Node.js base image. We need to change ownership of the copied files to avoid runtime errors.

USER node
# The USER instruction runs all subsequent instructions as the provided user.

EXPOSE 8000

ENTRYPOINT ["node"]

CMD ["app.js"]
```

Clone the GitHub repository and change into the folder where the advanced Containerfile is located:

```
git clone https://github.com/IBM/csm-dach-cloud-native-labs.git
cd csm-dach-cloud-native-labs/day-1/advanced
```

Our Containerfile is ready - Let's build the image with _podman build_:

```
user1$ podman build -t mynode:1.0 .
[1/2] STEP 1/4: FROM node@sha256:534004248435dea5cecf3667232f800fc6bd101768306aecf6b87d78067b0563 AS builder
[1/2] STEP 2/4: WORKDIR /app
--> 52d9b363171
[1/2] STEP 3/4: COPY ["app.js", "package.json", "/app/"]
...
Successfully tagged localhost/mynode:1.0
38e4c41581ea9078518acb80d76c673179acffba0bceffb0c594b64dc033bf2c
```

Note the difference in how the build steps are displayed **"[1/2] STEP 1/4:"**... The different stages are indicated before each stage's step.

In the list of images, we see both the image we created and the base image:

```
user1:~$ podman images

REPOSITORY              TAG         IMAGE ID      CREATED             SIZE
localhost/mynode        1.0         38e4c41581ea  About a minute ago  117 MB
<none>                  <none>      4e77f2d7a0fd  2 minutes ago       934 MB
docker.io/library/node  <none>      affe728e127a  7 weeks ago         928 MB
docker.io/library/node  <none>      710c8aa630d5  7 weeks ago         113 MB
```

The resulting mynode image is only **117MB** in size. Compared to its build stage base image of **928MB**, this is quite some improvement!

Notice the weird looking image labeled **none**? This is a chached image, which was automatically created after completing the first stage. Use the option --layers=false in your podman build command to change this default behavior.

Run a container from this image:

```
user1:~$ podman run -d --name mynode -p 8000:8000 mynode
070a1c98224fec49e050408425f0f515b332815d3196c57ec054216731483a1d

user1:cloud-native-labs$ podman ps
CONTAINER ID  IMAGE                 COMMAND     CREATED        STATUS            PORTS                   NAMES
070a1c98224f  localhost/mynode:1.0  app.js      8 seconds ago  Up 8 seconds ago  0.0.0.0:8000->8000/tcp  mynode
```

Let's test our app

```
user1:~$ curl localhost:8000
Hello raphael. This message comes from inside the container!
```

When we look at the Node.js application's source code, we see that the name "raphael" was injected via the environment variable **username**, which we defined during the container image build.

```js
app.get("/", (req, res) => {
  res.send(
    `Hello ${process.env.username}. This message comes from inside the container!\n`
  );
});
```

It looks like it's working as expected :)

Let's clean up our work by removing all containers and images

```
user1:~$ podman stop -a
070a1c98224fec49e050408425f0f515b332815d3196c57ec054216731483a1d

user1:~$ podman rm -a
070a1c98224fec49e050408425f0f515b332815d3196c57ec054216731483a1d

user1:~$ podman rmi -a
Untagged: docker.io/library/node@sha256:8569c8f07454ec42501e5e40a680e49d3f9aabab91a6c149e309bac63a3c8d54
Untagged: localhost/mynode:1.0
Deleted: 4e77f2d7a0fd986a4d4e6ca23186c5c6021e946ff819b45711cec2b9985ec6a9
Deleted: 38e4c41581ea9078518acb80d76c673179acffba0bceffb0c594b64dc033bf2c
```
