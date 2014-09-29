#!/bin/bash
set +x

## Set up a custom password
PASSWORD=$(pwgen -c -n -1 12)

## Little bit of error checking here
if ! [[ $VNCDISPLAY -ge 0 && $VNCDISPLAY -lt 100 ]]; then
    echo "No valid VNCPORT specified, so we're just going to use 1"
    VNCDISPLAY=1
fi

VNCPORT="59$(printf "%02d\n" ${VNCDISPLAY})"

echo "PASSWORD=${PASSWORD}" >> /tmp/.debug
echo "VNCPORT=${VNCPORT}" >> /tmp/.debug

## This is a hack until volume permissions are working
##   https://github.com/docker/docker/issues/3124
sudo /bin/chown -R guest /home/guest

## Make sure this exists
if ! [ -d /home/guest/.vnc ]; then
    echo "Creating /home/guest/.vnc"
    mkdir /home/guest/.vnc
fi


cat > /home/guest/.vnc/xstartup << "EOF"
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
OS=`uname -s`
if [ -x /etc/X11/xinit/xinitrc ]; then
  exec /etc/X11/xinit/xinitrc
fi
if [ -f /etc/X11/xinit/xinitrc ]; then
  exec sh /etc/X11/xinit/xinitrc
fi
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey

fluxbox &
EOF

sudo /bin/chmod 750 /home/guest/.vnc/xstartup

cat > /home/guest/.Xclients << "EOF"
#!/bin/bash

dbus-daemon --session --fork

xterm &

fluxbox &
EOF
sudo /bin/chmod 750 /home/guest/.Xclients

x11vnc -storepasswd $PASSWORD /home/guest/.vnc/passwd
sed -i "s/:VNCPASSWORD:/${PASSWORD}/g" /etc/guacamole/noauth-config.xml
sed -i "s/:VNCPORT:/${VNCPORT}/g" /etc/guacamole/noauth-config.xml

sudo service guacd start
sudo service tomcat6 start
#sed -i '/\/etc\/X11\/xinit\/xinitrc-common/a /usr/bin/firefox &' /etc/X11/xinit/xinitrc
#x11vnc -forever -usepw -create  -geometry 1268x1024
vncserver :$VNCDISPLAY -name "Duke University Testing Image"

#tail -F /var/log/tomcat6/catalina.out
export GUACAMOLE_HOME=/etc/guacamole
/bin/bash
