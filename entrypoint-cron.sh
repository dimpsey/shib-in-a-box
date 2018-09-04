#!/bin/sh

set -e

/usr/local/bin/get-sealer-keys >/var/shib-keys/keys
chmod 444 /var/shib-keys/keys

exec /usr/sbin/cron -f
