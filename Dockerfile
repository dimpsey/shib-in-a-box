FROM centos:7

MAINTAINER Technology Services, University of Illinois Urbana

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu 

COPY yum/*.repo /etc/yum.repos.d/

RUN yum -y install \
       shibboleth \
    && rm -f /etc/shibboleth/{*.config,*.dist,shibd-*,example-*,*.pem} \
             /etc/shibboleth/{attribute-map.xml,native.logger,shibd.logger} \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && cd /etc/shibboleth \
    && curl -so /etc/shibboleth/itrust.pem \
       "${DISCOVERY_SVC_URL}/itrust-certs/itrust.pem" \
    && curl -so  /var/cache/shibboleth/itrust-metadata.xml \
       "${DISCOVERY_SVC_URL}/itrust-metadata/itrust-metadata.xml"

COPY shibboleth/* /etc/shibboleth/

RUN chmod 644 /var/cache/shibboleth/itrust-metadata.xml \
       /etc/shibboleth/itrust.pem \
    && chown shibd:shibd /var/cache/shibboleth/itrust-metadata.xml
