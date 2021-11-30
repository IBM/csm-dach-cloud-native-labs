FROM redhat/ubi8
# The FROM command tell us which is the base image. We are using a dockerhub image published by RedHat. 
# https://hub.docker.com/r/redhat/ubi8

MAINTAINER eramon
# The MAINTAINER command tells who is the author of the Containerfile

LABEL description="My very own Apache Server"
# The LABEL is optional but useful to provide information about the image

RUN yum install -y httpd &&\
    yum clean all
# The RUN command is executed during build
# Each RUN command adds a layer to the image, so it's a good practice to use && to combine commands 

EXPOSE 80
# The EXPOSE command says which port on the container should be exposed (metadata only)

ENTRYPOINT ["httpd"]
# The ENTRYPOINT is the command to be executed on the container when it is started 
# The entrypoint can't be overriden

CMD ["-D", "FOREGROUND"]
# The CMD command provides the parameters for the command specified in ENTRYPOINT
# The arguments can be overriden by passing them at the end of _podman run_
