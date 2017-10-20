#!/bin/sh

# ------------------------------------------------------------------------------
#
# entrypoint-shibd.sh
#
#     Edit shibboleth2.xml to add SP-specific details and start shibd 
#     in the foreground.
#
# FILES
#
#     /etc/shibboleth/shibboleth2.xml
#         Configuration file for shibd to be edited.
#
# ENVIRONMENT
#
#   SHIBD_ACL
#         ACL for TCPListener. Set in docker-compose.yml.
#
#   SHIBD_ENTITYID
#         Entity ID value this SP was/will be registered to iTrust
#         with. Set in docker-compose.yml.
#
#   SHIBD_IDP
#         Identifier for the shibboleth IdP to use. Set in 
#         docker-compose.yml.
#
# ------------------------------------------------------------------------------

set -e

sed -i -e "s/SHIBD_ENTITYID/$SHIBD_ENTITYID/g" \
    -e "s/SHIBD_ACL/$SHIBD_ACL/g" \
    -e "s/SHIBD_IDP/$SHIBD_IDP/g" /etc/shibboleth/shibboleth2.xml

exec /usr/sbin/shibd -F -f
