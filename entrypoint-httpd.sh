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
# ENVIRONMENT
#
#   APP_SERVER_NAME
#           Server name used as the HTTP host. Set in
#           docker-compose.yml
#
#   SHIBD_ACL
#           ACL for TCPListener. Set in docker-compose.yml.
#
#   SHIBD_HOSTNAME
#           Name of the container (host) running shibd. Set in 
#           docker-compose.yml.
#
#   SHIBD_IDP
#           Identifier fro the shibboleth IdP to use. Set in 
#           docker-compose.yml.
#
# -----------------------------------------------------------------------------

set -e 

SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')

sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" \
    -e "s/APP_SERVER_NAME/$APP_SERVER_NAME/g" \
    -e "s/SHIBD_ACL/$SHIBD_ACL/g" \
    -e "s/SHIBD_IDP/$SHIBD_IDP/g" /etc/shibboleth/shibboleth2.xml

exec httpd -DFOREGROUND
