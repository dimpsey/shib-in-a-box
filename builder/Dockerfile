FROM techservicesillinois/shibd-base as builder

COPY dereflinks /usr/local/bin/
COPY make_layers.sh manifest.* /tmp/

WORKDIR /tmp
RUN ./make_layers.sh

######################################

FROM scratch

COPY --from=builder /tmp/fakeroot/ /
