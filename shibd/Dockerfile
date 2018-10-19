FROM golang:alpine as golang

ENV SRC=get-shib-keys

RUN apk update && apk add git make upx

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress

####################################

FROM techservicesillinois/shibd-base as builder

COPY manifest /tmp/

WORKDIR /tmp
RUN ldd `cat manifest` | grep -o '/.\+\.so[^ :]*' | sort -u >> manifest
RUN sort -u manifest -o manifest

RUN tar chf bash.tar -T manifest
RUN mkdir /tmp/fakeroot \
    && mkdir -m 1777 /tmp/fakeroot/tmp

RUN tar xf /tmp/bash.tar -C /tmp/fakeroot

#####################################

FROM techservicesillinois/httpd-shibd-common

COPY --from=builder /tmp/fakeroot /
COPY --from=builder --chown=shibd:shibd /var/run/shibboleth /var/run/shibboleth
COPY --from=golang /go/src/get-shib-keys /usr/local/bin/

COPY shibboleth2.xml.shibd /var/run/shibboleth/shibboleth2.xml
COPY entrypoint-shibd.sh /usr/local/bin/

VOLUME ["/var/shib-keys"]

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    LANG=C

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/usr/local/bin/entrypoint-shibd.sh" ]
# ENTRYPOINT [ "/usr/bin/strace",  "-ff", "-o", "/tmp/log", "/bin/sh", "/usr/local/bin/entrypoint-shibd.sh" ]
# ENTRYPOINT [ "/usr/bin/strace",  "-ff", "/bin/sh", "/usr/local/bin/entrypoint-shibd.sh" ]
