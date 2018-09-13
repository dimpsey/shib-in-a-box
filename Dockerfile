FROM centos:7

MAINTAINER Technology Services, University of Illinois Urbana

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu 

COPY yum/*.repo /etc/yum.repos.d/

RUN yum -y install \
       shibboleth \
    && rm --interactive=never /etc/shibboleth/{*.config,*.dist,*.pem} \
    && rm --interactive=never /etc/shibboleth/{shibd-*,example-*} \
    && rm --interactive=never /etc/shibboleth/{attribute-map.xml,native.logger,shibd.logger,shibboleth2.xml} \
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
