FROM alpine

COPY --from=techservicesillinois/httpd-shibd-common /sha256sum.txt /tmp/sha256sum.common.txt
COPY --from=techservicesillinois/shibd-builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.common.txt /tmp/sha256sum.builder.txt

##########################################

FROM techservicesillinois/httpd-shibd-common

COPY --from=techservicesillinois/shibd-builder /shibd/ /
COPY entrypoint.sh /

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    LANG=C

VOLUME ["/etc/shibboleth", "/var/shib-keys"]

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/entrypoint.sh" ]
