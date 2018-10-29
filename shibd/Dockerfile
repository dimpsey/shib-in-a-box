FROM techservicesillinois/httpd-shibd-common

COPY --from=techservicesillinois/httpd-shibd-builder /shibd/ /
COPY entrypoint.sh /

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    LANG=C

VOLUME ["/etc/shibboleth", "/var/shib-keys"]

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/entrypoint.sh" ]
