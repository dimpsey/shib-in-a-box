ARG  TAG=latest
ARG  HEALTHCHECK_TAG=latest

FROM techservicesillinois/shibd-common:$TAG as common
FROM techservicesillinois/shibd-builder:$TAG as builder
FROM techservicesillinois/healthcheck:$HEALTHCHECK_TAG as healthcheck

##########################################

FROM alpine

COPY --from=common /sha256sum.txt /tmp/sha256sum.common.txt
COPY --from=builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.common.txt /tmp/sha256sum.builder.txt

##########################################

FROM common

ARG TAG
ENV SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    LOG_LEVEL=info \
    JK_LOG_LEVEL=info

COPY --from=builder /httpd/ /
COPY --from=healthcheck /healthcheck /

# TODO: this is a workaround. so we can remove files
# refactor all configuration into a seperate container. so this 
# container can read-only
COPY --chown=apache:apache root/ /

USER apache
EXPOSE 8080

# TODO This should be config be pulled from config!
# TODO will need to add the option to configure healthcheck with a
#      file
HEALTHCHECK CMD /healthcheck \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Metadata \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Status \
    -c 204 http://localhost:8080/auth/elmr/status

ENTRYPOINT ["/entrypoint.sh"]
