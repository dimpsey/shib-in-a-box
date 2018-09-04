#!/bin/sh

set -e

/usr/local/bin/get-sealer-keys

exec /usr/sbin/cron -f
