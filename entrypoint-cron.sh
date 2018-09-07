#!/bin/sh

set -e
# set -x # DEBUG

# Make sure user set necessary environment variables
[ -z "$SECRET_ID" ] && echo "Need to set SECRET_ID!" && exit 2
[ -z "$SCHEDULE" ] && echo "Need to set SCHEDULE!" && exit 3

# create pipes used by cron script for Docker logging
mkfifo -m 660 /tmp/stdout /tmp/stderr
chgrp shibd /tmp/stderr /tmp/stdout

# Make sure ${KEYS} is owned by the shibd user
mkdir -p 700 ${KEYS}        # NOOP if director exists
chmod 0700 ${KEYS}
chown ${USR}:${USR} ${KEYS}
chmod g+s ${KEYS}

# Run get-sealer-keys as shibd user so that shibd can read its output!
su -s /bin/sh -c "/usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID" shibd
su -s /bin/sh -c "echo '$SCHEDULE /usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID >/tmp/stdout 2>/tmp/stdout' | crontab -" shibd

# Create root crontabs to redirect pipe contents to the Docker logger
echo "$SCHEDULE cat /tmp/stdout >/proc/1/fd/1" | crontab -

exec /usr/sbin/crond -n -m off
