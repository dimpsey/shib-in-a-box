#!/bin/bash

set -e

TIME=0.1
KEYS=/var/shib-keys/keys
CONFIG=/var/run/shibboleth/shibboleth2.xml

if [ -z "$HTTPD_HOSTNAME"]; then
    # Assuming we are running in Fargate mode
    export SHIBD_IP="127.0.0.1"
else
    # Assuming we are running in Bridge mode or docker-compose
    echo "Waiting for HTTPD IP to become avaliable..."
    while [ -z "$HTTPD_IP" ]; do
        HTTPD_IP=$(getent ahosts $HTTPD_HOSTNAME | awk 'NR==1{ print $1 }')
        echo "    Sleeping for $TIME seconds."
        sleep $TIME
    done
    echo "HTTPD IP is $HTTPD_IP."
fi

echo -n "Waiting for $KEYS..."
while [ ! -s $KEYS ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $KEYS!"

/usr/local/bin/get-shib-keys /service/shibd 

sed -i -e "s/SHIBD_ACL/$HTTPD_IP/g" $CONFIG

exec /usr/sbin/shibd -F -f -c $CONFIG
