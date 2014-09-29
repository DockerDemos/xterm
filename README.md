guacamole-base
==============

Base image for running an X11 application in a web browser within Docker

This image will contain several parts:

* Tigervnc server to run X11
* Tomcat server to run guacamole
* Fluxbox keep window management simple

The intent is not never use build off of this image and create app specific
images for your docker needs

Security
========

Currently, there is no authentication used to connect to the Guacamole process.
Some sort of external authentication and authorization is intended to be used
with this

Example Usage
=============
docker build -t guac .
export PUBLICPORT=8080
export VNCDISPLAY=1

docker run \
    -p "${PUBLICPORT}:8080" \
    -v "/tmp/guest-${PUBLICPORT}:/home/guest" \
    --rm=true -i --tty=true \
    -e "VNCDISPLAY=${VNCDISPLAY}" \
    guac
