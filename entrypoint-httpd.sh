#!/bin/sh

# -----------------------------------------------------------------------------
#
# Edit shibboleth2.xml to put in the IP address of the container running shibd 
# and start httpd in the foreground.
#
#
# FILES
#
#   /etc/shibboleth/shibboleth2.xml
#           Configuration file for mod_shib to be edited, setting
#           the IP address of the container running shibd.
#
#   /etc/httpd/conf/httpd.conf
#           Configuration file for httpd to be edited. Edit will
#           set the value of the ServerName directive.
#
# ENVIRONMENT
#
#   SHIBD_HOSTNAME
#           Name of the container (host) running shibd. Set in 
#           docker-compose.yml. If not set then assume 127.0.0.1.
#
# -----------------------------------------------------------------------------

set -e 

TIME=0.1

if [ -z "$SHIBD_HOSTNAME" ]; then
    # Assuming we are running awsvpc mode
    export SHIBD_IP="127.0.0.1"
else
    # Assuming we are running Bridge mode or docker-compose
    echo "Waiting for Shibboleth IP to become avaliable..."
    while [ -z "$SHIBD_IP" ]; do
        export SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')
        echo "    Sleeping for $TIME seconds."
        sleep $TIME
    done
    echo "Shibboleth IP is $SHIBD_IP."
fi

if [ -z "$ELMR_HOSTNAME" ]; then
    # Assuming we are running awsvpc mode
    export ELMR_IP="127.0.0.1"
else
    # Assuming we are running Bridge mode or docker-compose
    echo "Waiting for elmr IP to become avaliable..."
    while [ -z "$ELMR_IP" ]; do
        export ELMR_IP=$(getent ahosts $ELMR_HOSTNAME | awk 'NR==1{ print $1 }')
        echo "    Sleeping for $TIME seconds."
        sleep $TIME
    done
    echo "elmr IP is $ELMR_IP."
fi

sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" /etc/shibboleth/shibboleth2.xml

exec httpd -DFOREGROUND
