#!/bin/bash

set -e

KEYS=/var/shib-keys/keys
TIME=0.1

while [ ! -s $KEYS ]; do
    echo "Waiting $TIME for $KEYS"
    sleep $TIME
done

/usr/local/bin/get-shib-keys /service/shibd 
chgrp -R shibd /etc/shibboleth

# exec su -s /bin/sh -c "/usr/sbin/shibd -F -f" shibd
exec chroot --userspec=shibd / /usr/sbin/shibd -F -f
