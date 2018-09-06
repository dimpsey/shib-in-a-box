#!/bin/sh

set -e

su -s /bin/sh -c "/usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID" shibd
su -s /bin/sh -c "echo '* * * * * /usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID >/dev/pts/0 2>/dev/pts/0' | crontab -" shibd

exec /usr/sbin/crond -n -m off
