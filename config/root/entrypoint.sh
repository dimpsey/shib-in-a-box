#!/bin/sh

set -e

function get_ip_addr() {
    # $1 is var to set with IP
    # $2 is hostname to lookup
    local TIME=0.1
    local IP

    if [ -z "$2" ]; then
        # Assuming we are running in awsvpc mode
        IP="127.0.0.1"
    else
        # Assuming we are running in Bridge mode or docker-compose
        echo "Waiting for IP to become avaliable from HOST '$2'..."
        while [ -z "$IP" ]; do
            IP=$(getent ahosts $2 | awk 'NR==1{ print $1 }')
            echo "    Sleeping for $TIME seconds."
            sleep $TIME
        done
        echo "HOST $2 has the IP: $IP."
    fi

    eval export $1=$IP
}

get_ip_addr HTTPD_IP "$HTTPD_HOSTNAME"
get_ip_addr SHIBD_IP "$SHIBD_HOSTNAME"

# TODO '/service/shibd' needs to be configurable by ENV VAR!
/usr/local/bin/get-shib-keys /service/shibd 

sed -i -e "s/SHIBD_ACL/$HTTPD_IP/g" \
       -e "s/SHIBD_IP/$SHIBD_IP/g" \
    $SHIBSP_CONFIG_TEMPLATE

mv $SHIBSP_CONFIG_TEMPLATE $SHIBSP_CONFIG
