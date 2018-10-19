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
#FROM techservicesillinois/shibd-base
#
#RUN yum -y install \
#     httpd \
#     && yum clean all \
#     && rm -rf /var/cache/yum \
#     && rm /etc/httpd/conf/httpd.conf \
#     && rm /etc/httpd/conf.d/*
ENV SHIBSP_CONFIG=/var/run/httpd/shibboleth2.xml

COPY --from=builder /tmp/fakeroot /
COPY --from=builder --chown=apache:apache /tmp/fakeroot/etc /etc
COPY --from=builder --chown=apache:apache /tmp/fakeroot/var/run /var/run
COPY --from=builder --chown=apache:apache /tmp/fakeroot/run /run

COPY test-httpd.sh /usr/local/bin/test.sh
COPY --chown=apache:apache shibboleth2.xml ${SHIBSP_CONFIG}
COPY --chown=apache:apache httpd/ /etc/httpd/
COPY --chown=apache:apache environment /var/www/cgi-bin/
COPY --from=builder /usr/lib64/httpd/modules/mod_jk.so /usr/lib64/httpd/modules/
COPY entrypoint-httpd.sh /usr/local/bin/

#RUN chown -R root:apache /etc/shibboleth \
#     && chown -R root:apache /etc/httpd \
#     && chmod -R g+rw /etc/shibboleth \
#     && chmod -R g+rw /etc/httpd/conf \
#     && chmod g+rw /var/run/httpd

#RUN chown -R root:apache /etc/shibboleth \
#     && chown -R root:apache /etc/httpd \
#     && chmod -R g+rw /etc/shibboleth \
#     && chmod -R g+rw /etc/httpd/conf \
#     && chmod g+rw /etc/httpd/conf/httpd.conf \
#     && chmod g+rw /var/run/httpd

USER apache
EXPOSE 8080 

HEALTHCHECK CMD test.sh

ENTRYPOINT ["entrypoint-httpd.sh"]
