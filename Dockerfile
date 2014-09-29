FROM centos:centos6
MAINTAINER Drew Stinnett <drews@duke.edu>

## Initial stuff to install
RUN yum -y install tomcat6 epel-release

## Install Everythingj
RUN yum -y install tigervnc-server tigervnc libguac-client-* guacd x11vnc \
  unzip xorg-x11-server-Xvfb xorg-x11-twm xorg-x11-font xulrunner \
  xorg-x11-xinit \
  fluxbox \
  sudo \
  pwgen \
  dejavu-sans-fonts dejavu-serif-fonts xdotool gnome-terminal firefox

RUN yum -y install xterm

## Configure Userspace
VOLUME /home/guest
RUN useradd guest

## Set up application
RUN mkdir -p /var/lib/guacamole/classpath /etc/guacamole

## Downloaded from: http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-0.8.3.war/download
COPY guacamole-0.8.3.war /var/lib/tomcat6/webapps/guacamole.war
COPY guacamole-auth-noauth-0.9.0.jar /var/lib/guacamole/classpath/guacamole-auth-noauth-0.9.0.jar
COPY run.sh /run.sh
RUN chmod 644 /var/lib/tomcat6/webapps/guacamole.war
RUN chmod 755 /run.sh
RUN echo "export GUACAMOLE_HOME=/etc/guacamole" > /etc/profile.d/guacamole.sh
RUN echo "setenv GUACAMOLE_HOME /etc/guacamole" > /etc/profile.d/guacamole.csh
COPY guacamole.properties /etc/guacamole/guacamole.properties
COPY noauth-config.xml /etc/guacamole/noauth-config.xml
RUN chown -R guest:tomcat /etc/guacamole

COPY sudo.txt /etc/sudoers.d/guest_privs

## Remove this eventually?
COPY server.xml /etc/tomcat6/server.xml
RUN chown -R tomcat /var/lib/guacamole

## Fix up permissions
RUN dbus-uuidgen > /var/lib/dbus/machine-id
RUN chown -R guest /home/guest

USER guest

CMD /run.sh
