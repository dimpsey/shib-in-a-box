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
#   APP_SERVER_NAME
#           Name of the application server (the host name or 
#           virtual host name). Set in docker-compose.yml.
#
#   SHIBD_HOSTNAME
#           Name of the container (host) running shibd. Set in 
#           docker-compose.yml.
#
# -----------------------------------------------------------------------------

set -e 

TIME=0.1

# Make sure user set necessary environment variables
[ -z "$APP_SERVER_NAME" ] && echo "APP_SERVER_NAME is not set!" && exit 3

if [ -z "$SHIBD_HOSTNAME"]; then
    # Assuming we are running Fargate mode
    export SHIBD_IP="127.0.0.1"
else
    # Assuming we are running Bridge mode or docker-compose
    echo "Waiting for Shibboleth IP to become avaliable..."
    while [ -z "$SHIBD_IP" ]; do
        SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')
        echo "    Sleeping for $TIME seconds."
        sleep $TIME
    done
    echo "Shibboleth IP is $SHIBD_IP."
fi

sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" \
    -e "s/APP_SERVER_NAME/$APP_SERVER_NAME/g" \
    -e "s/SHIBD_IDP/$SHIBD_IDP/g" /etc/shibboleth/shibboleth2.xml

sed -i -e "s/APP_SERVER_NAME/$APP_SERVER_NAME/g" \
    /etc/httpd/conf/httpd.conf

exec httpd -DFOREGROUND
