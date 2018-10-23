FROM centos:7 as builder

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu 

COPY shib.repo /etc/yum.repos.d/

# TODO Should itrust really be here? No...
RUN yum -y install \
       httpd \
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
       "${DISCOVERY_SVC_URL}/itrust-metadata/itrust-metadata.xml" \
    && rm /etc/httpd/conf/httpd.conf \
    && rm /etc/httpd/conf.d/*

##############################################

FROM builder as modjk

RUN yum -y install \
	 httpd-devel \
     gcc \
     gcc-c++ \
     make \
     libtool \
     && cd /tmp \
     && curl -so mod_jk.tar.gz http://www.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.44-src.tar.gz \
     && tar -xzf mod_jk.tar.gz \
     && yum clean all \
     && rm -rf /var/cache/yum

RUN cd /tmp/tomcat-connectors-1.2.44-src/native \
     && ./buildconf.sh \
     && ./configure --with-apxs=/usr/bin/apxs \
     && make \
     && make install

######################################

FROM builder

MAINTAINER Technology Services, University of Illinois Urbana

COPY --from=modjk /usr/lib64/httpd/modules/mod_jk.so /usr/lib64/httpd/modules/
