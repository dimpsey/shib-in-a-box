FROM techservicesillinois/shibd-base as builder

COPY manifest /tmp/

WORKDIR /tmp
# Move modules to manifest!
RUN ldd `cat manifest` /etc/httpd/modules/* | grep -o '/.\+\.so[^ :]*' | sort -u >> manifest
RUN sort -u manifest -o manifest

RUN tar chf bash.tar -T manifest
RUN mkdir /tmp/fakeroot \
    && mkdir -p -m 755 /tmp/fakeroot/var/www/html \
    && mkdir -p -m 755 /tmp/fakeroot/run/httpd \
    && mkdir -m 1777 /tmp/fakeroot/tmp

RUN tar xf /tmp/bash.tar -C /tmp/fakeroot

######################################

FROM techservicesillinois/httpd-shibd-common

ENV SHIBSP_CONFIG=/var/run/httpd/shibboleth2.xml

COPY --from=builder /tmp/fakeroot /
COPY --from=builder --chown=apache:apache /tmp/fakeroot/etc /etc
COPY --from=builder --chown=apache:apache /tmp/fakeroot/var/run /var/run
COPY --from=builder --chown=apache:apache /tmp/fakeroot/run /run

COPY --chown=apache:apache shibboleth2.xml ${SHIBSP_CONFIG}
COPY --chown=apache:apache httpd/ /etc/httpd/
COPY --chown=apache:apache environment /var/www/cgi-bin/
COPY --from=builder /usr/lib64/httpd/modules/mod_jk.so /usr/lib64/httpd/modules/
COPY entrypoint-httpd.sh /usr/local/bin/

USER apache
EXPOSE 8080 

HEALTHCHECK CMD /healthcheck \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Metadata \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Status \
    -c 204 http://localhost:8080/auth/elmr/status

ENTRYPOINT ["entrypoint-httpd.sh"]
