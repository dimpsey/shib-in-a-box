#!/bin/sh

set -e 

TIME=0.1
CONFIG=/var/shib-keys/keys

echo "Waiting for $CONFIG..."
while [ ! -s "$CONFIG" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $CONFIG!"

exec httpd -DFOREGROUND
