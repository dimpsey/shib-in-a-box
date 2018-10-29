#!/bin/sh

set -e

TIME=0.1
KEYS=/var/shib-keys/keys

echo "Waiting for $KEYS..."
while [ ! -s "$KEYS" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $KEYS!"

exec /usr/sbin/shibd -F -f
