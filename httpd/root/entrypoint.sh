#!/bin/sh

set -e 

TIME=0.1

echo "Waiting for $SHIBSP_CONFIG..."
while [ ! -s "$SHIBSP_CONFIG" ]; do
    echo "    Sleeping for $TIME seconds."
    sleep $TIME
done
echo "Found $SHIBSP_CONFIG!"

exec httpd -DFOREGROUND
