FROM golang:alpine as golang

ENV SRC=get-shib-keys

RUN apk update && apk add git make upx

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress

####################################

FROM techservicesillinois/shibd-base

COPY --from=techservicesillinois/httpd-shibd-builder /config/ /
COPY --from=golang /go/src/get-shib-keys /usr/local/bin/

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
