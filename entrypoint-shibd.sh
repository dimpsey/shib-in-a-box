#!/bin/bash

set -e

# Make sure user set necessary environment variables
[ -z "$HTTPD_HOSTNAME" ] && echo "HTTPD_HOSTNAME is not set!" && exit 2

CONFIG=/var/run/shibboleth/shibboleth2.xml

echo -n "Waiting for HTTPD IP to become avaliable"
while [ -z "$HTTPD_IP" ]; do
    HTTPD_IP=$(getent ahosts $HTTPD_HOSTNAME | awk 'NR==1{ print $1 }')
    echo -n "."
    sleep 0.1
done
echo " HTTPD IP is $HTTPD_IP."

KEYS=/var/shib-keys/keys

echo -n "Waiting for $KEYS"
while [ ! -s $KEYS ]; do
    echo "."
    sleep 0.1
done
echo " done."

/usr/local/bin/get-shib-keys /service/shibd 

sed -i -e "s/SHIBD_ACL/$HTTPD_IP/g" $CONFIG

exec /usr/sbin/shibd -F -f -c $CONFIG
