#!/bin/sh

# -----------------------------------------------------------------------------
#
# Edit shibboleth2.xml to put in the IP address of the container running shibd 
# and start httpd in the foreground.
#
#
# FILES
#
#   /etc/shibboleth/shibboleth2.xml
#           Configuration file for mod_shib to be edited, setting
#           the IP address of the container running shibd.
#
#   /etc/httpd/conf/httpd.conf
#           Configuration file for httpd to be edited. Edit will
#           set the value of the ServerName directive.
#
# ENVIRONMENT
#
#   APP_SERVER_NAME
#           Name of the application server (the host name or 
#           virtual host name). Set in docker-compose.yml.
#
#   SHIBD_ACL
#           ACL for TCPListener. Set in docker-compose.yml.
#
#   SHIBD_HOSTNAME
#           Name of the container (host) running shibd. Set in 
#           docker-compose.yml.
#
# -----------------------------------------------------------------------------

set -e 

SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')

sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" \
    -e "s/SHIBD_ACL/$SHIBD_ACL/g" \
    -e "s/APP_SERVER_NAME/$APP_SERVER_NAME/g" \
    -e "s/SHIBD_IDP/$SHIBD_IDP/g" /etc/shibboleth/shibboleth2.xml

sed -i -e "s/APP_SERVER_NAME/$APP_SERVER_NAME/g" \
    /etc/httpd/conf/httpd.conf

exec httpd -DFOREGROUND
