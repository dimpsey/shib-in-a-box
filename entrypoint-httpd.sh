#!/bin/sh

# -----------------------------------------------------------------------------
#
# entrypoint-httpd.sh
#
#     Edit shibboleth2.xml to put in the IP address of the container 
#     running shibd and start httpd in the foreground.
#
# FILES
#
#   /etc/shibboleth/shibboleth2.xml
#           Configuration file for mod_shib to be edited, setting
#           the IP address of the container running shibd.
#
# ENVIRONMENT
#
#   SHIBD_ACL
#           ACL for TCPListener. Set in docker-compose.yml.
#
#   SHIBD_ENTITYID
#         Entity ID value this SP was/will be registered to iTrust
#         with. Set in docker-compose.yml.
#
#   SHIBD_HOSTNAME
#         Name of the shibd host container. Set in 
#         docker-compose.yml.
#
#   SHIBD_IDP
#           Identifier for the shibboleth IdP to use. Set in 
#           docker-compose.yml.
#
# -----------------------------------------------------------------------------

set -e 

SHIBD_IP=$(getent ahosts $SHIBD_HOSTNAME | awk 'NR==1{ print $1 }')

sed -i -e "s/SHIBD_IP/$SHIBD_IP/g" \
    -e "s/SHIBD_ENTITYID/$SHIBD_ENTITYID/g" \
    -e "s/SHIBD_ACL/$SHIBD_ACL/g" \
    -e "s/SHIBD_IDP/$SHIBD_IDP/g" /etc/shibboleth/shibboleth2.xml

exec httpd -DFOREGROUND
