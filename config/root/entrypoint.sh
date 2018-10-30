#!/bin/sh

set -e

function get_ip_addr() {
    # $1 is var to set with IP
    # $2 is hostname to lookup
    TIME=0.1

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

sed    -e "s/SHIBD_ACL/$HTTPD_IP/g" $SHIBSP_CONFIG_TEMPLATE > /tmp/shibd
sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" /tmp/shibd

sed    -e "s/SHIBD_ACL/$HTTPD_IP/g" $SHIBSP_CONFIG_TEMPLATE > /tmp/httpd
sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" /tmp/httpd

mv /tmp/shibd $SHIBSP_CONFIG
mv /tmp/httpd $HTTPD_SHIBSP_CONFIG

################################################################
#set -e 
#
#TIME=0.1
#HTTPD_CONF=/etc/httpd/conf/httpd.conf
#
#if [ -z "$ELMR_HOSTNAME" ]; then
#    # Assuming we are running awsvpc mode
#    export ELMR_IP="127.0.0.1"
#else
#    # Assuming we are running Bridge mode or docker-compose
#    echo "Waiting for elmr IP to become avaliable..."
#    while [ -z "$ELMR_IP" ]; do
#        export ELMR_IP=$(getent ahosts $ELMR_HOSTNAME | awk 'NR==1{ print $1 }')
#        echo "    Sleeping for $TIME seconds."
#        sleep $TIME
#    done
#    echo "elmr IP is $ELMR_IP."
#fi
#
#if [ -z "$LB_HOSTNAME" ]; then
#    sed -i -e "/LB_HOSTNAME/d" $HTTPD_CONF
#else
#    sed -i -e "s/LB_HOSTNAME/$LB_HOSTNAME/g" $HTTPD_CONF
#fi
#
#sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" $SHIBSP_CONFIG
#
#exec httpd -DFOREGROUND