#!/bin/bash

set -e

KEYS=/var/shib-keys/keys
TIME=0.1

while [ ! -s $KEYS ]; do
    echo "Waiting $TIME for $KEYS"
    sleep $TIME
done
echo "---------------------"
cat $KEYS
echo "---------------------"
exec /usr/sbin/shibd -F -f
