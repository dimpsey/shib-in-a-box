FROM alpine

COPY --from=techservicesillinois/shibd-common /sha256sum.txt /tmp/sha256sum.common.txt
COPY --from=techservicesillinois/shibd-builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.common.txt /tmp/sha256sum.builder.txt

##########################################

FROM techservicesillinois/shibd-common

ENV SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    LOG_LEVEL=info \
    JK_LOG_LEVEL=info

COPY --from=techservicesillinois/shibd-builder /httpd/ /
COPY --from=techservicesillinois/http-status /healthcheck /

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
