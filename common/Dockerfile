FROM techservicesillinois/shibd-base as builder

COPY manifest /tmp/

WORKDIR /tmp
RUN ldd `cat manifest` | grep -o '/.\+\.so[^ :]*' | sort -u >> manifest
RUN sort -u manifest -o manifest

RUN tar chf bash.tar -T manifest
RUN mkdir /tmp/fakeroot
RUN tar xf /tmp/bash.tar -C /tmp/fakeroot

COPY shibboleth/* /tmp/fakeroot/etc/shibboleth/

######################################

FROM scratch

COPY --from=builder /tmp/fakeroot /
