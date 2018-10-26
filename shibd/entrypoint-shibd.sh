#!/bin/sh

set -e

TIME=0.1
KEYS=/var/shib-keys/keys
CONFIG=/var/run/shibboleth/shibboleth2.xml

echo "Waiting for $KEYS..."
while [ ! -s "$KEYS" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $KEYS!"

exec /usr/sbin/shibd -F -f -c $CONFIG
