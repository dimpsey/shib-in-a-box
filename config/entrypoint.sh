#!/bin/sh

set -e

TIME=0.1
KEYS=/var/shib-keys/keys

if [ -z "$HTTPD_HOSTNAME" ]; then
    # Assuming we are running in awsvpc mode
    export SHIBD_IP="127.0.0.1"
else
    # Assuming we are running in Bridge mode or docker-compose
    echo "Waiting for IP to become avaliable from HOST '$HTTPD_HOSTNAME'..."
    while [ -z "$HTTPD_IP" ]; do
        HTTPD_IP=$(getent ahosts $HTTPD_HOSTNAME | awk 'NR==1{ print $1 }')
        echo "    Sleeping for $TIME seconds."
        sleep $TIME
    done
    echo "HTTPD IP is $HTTPD_IP."
fi

# TODO '/service/shibd' needs to be configurable by ENV VAR!
/usr/local/bin/get-shib-keys /service/shibd 

sed -i -e "s/SHIBD_ACL/$HTTPD_IP/g" $SHIBSP_CONFIG
