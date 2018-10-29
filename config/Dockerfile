FROM golang:alpine as golang

ENV SRC=get-shib-keys

RUN apk update && apk add git make upx

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress

####################################

FROM alpine as itrust

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu 

RUN mkdir -p /tmp/shibboleth \
    && wget -qO /tmp/shibboleth/itrust.pem \
       "${DISCOVERY_SVC_URL}/itrust-certs/itrust.pem" \
    && wget -qO /tmp/shibboleth/itrust-metadata.xml \
       "${DISCOVERY_SVC_URL}/itrust-metadata/itrust-metadata.xml"

####################################

FROM techservicesillinois/shibd-base

ENV SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml

COPY --from=techservicesillinois/httpd-shibd-builder /config/ /
COPY --from=golang /go/src/get-shib-keys /usr/local/bin/
COPY --chown=shibd:shibd --from=itrust /tmp/shibboleth/ /etc/shibboleth/

COPY /root/entrypoint.sh /
COPY --chown=shibd:shibd /root/etc/shibboleth/ /etc/shibboleth/

VOLUME ["/etc/shibboleth"]

#COPY --from=builder /tmp/fakeroot /
#COPY --from=builder --chown=apache:apache /tmp/fakeroot/etc /etc
#COPY --from=builder --chown=apache:apache /tmp/fakeroot/var/run /var/run
#COPY --from=builder --chown=apache:apache /tmp/fakeroot/run /run
#
#COPY --chown=apache:apache shibboleth2.xml ${SHIBSP_CONFIG}
#COPY --chown=apache:apache httpd/ /etc/httpd/
#COPY --chown=apache:apache environment /var/www/cgi-bin/
#COPY --from=builder /usr/lib64/httpd/modules/mod_jk.so /usr/lib64/httpd/modules/

# TODO
# COPY --from=builder --chown=shibd:shibd /var/run/shibboleth /var/run/shibboleth
ENTRYPOINT [ "/entrypoint.sh" ]
