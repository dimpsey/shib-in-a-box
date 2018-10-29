FROM techservicesillinois/httpd-shibd-common

COPY --from=techservicesillinois/httpd-shibd-builder /shibd/ /
COPY entrypoint.sh /

VOLUME ["/etc/shibboleth", "/var/shib-keys"]

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    LANG=C

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/entrypoint.sh" ]
