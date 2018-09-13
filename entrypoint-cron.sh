#!/bin/sh

set -e

STDOUT=/tmp/stdout

# Make sure user set necessary environment variables
[ -z "$SECRET_ID" ] && echo "SECRET_ID is not set!" && exit 2
[ -z "$SCHEDULE" ] && echo "SCHEDULE is not set!" && exit 3

# create pipe used by cron script for Docker logging
mkfifo -m 660 $STDOUT
chgrp $USR $STDOUT

# Make sure $KEYS is owned by the shibd user
mkdir -p 700 $KEYS        # NOOP if directory exists
chmod 0700 $KEYS
chown $USR:$USR $KEYS
chmod g+s $KEYS

# Run get-sealer-keys as shibd user so that shibd can read its output!
su -s /bin/sh -c "/usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID" $USR
su -s /bin/sh -c "echo '$SCHEDULE AWS_REGION="$AWS_REGION" /usr/local/bin/get-sealer-keys -f $KEYS/keys $SECRET_ID >$STDOUT 2>$STDOUT' | crontab -" $USR

# Create root crontabs to redirect pipe contents to the Docker logger
echo "$SCHEDULE cat $STDOUT >/proc/1/fd/1" | crontab -

exec /usr/sbin/crond -n -m off
