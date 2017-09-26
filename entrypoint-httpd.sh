#!/bin/bash

#
# Edit shibboleth2.xml to put in the IP address of the container running
# shibd and start httpd in the foreground.
#

set -e 

SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')

sed -i "s/SHIBD_IP/$SHIBD_IP/g" /etc/shibboleth/shibboleth2.xml
exec httpd -DFOREGROUND