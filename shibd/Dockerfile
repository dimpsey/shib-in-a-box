FROM techservicesillinois/httpd-shibd-common

COPY --from=techservicesillinois/httpd-shibd-builder /shibd/ /
COPY entrypoint-shibd.sh /usr/local/bin/

VOLUME ["/var/shib-keys"]

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    LANG=C

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/usr/local/bin/entrypoint-shibd.sh" ]
# ENTRYPOINT [ "/usr/bin/strace",  "-ff", "-o", "/tmp/log", "/bin/sh", "/usr/local/bin/entrypoint-shibd.sh" ]
# ENTRYPOINT [ "/usr/bin/strace",  "-ff", "/bin/sh", "/usr/local/bin/entrypoint-shibd.sh" ]
