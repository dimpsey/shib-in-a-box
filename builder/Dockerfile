FROM centos:7 as builder

COPY shib.repo /etc/yum.repos.d/

# TODO Should we keep the default httpd/shibd config files at all?
#       Probably not...
RUN yum -y install \
       httpd \
       shibboleth \
    && rm --interactive=never /etc/shibboleth/{*.config,*.dist,*.pem} \
    && rm --interactive=never /etc/shibboleth/{shibd-*,example-*} \
    && rm --interactive=never /etc/shibboleth/{attribute-map.xml,native.logger,shibd.logger,shibboleth2.xml} \
    && yum clean all \
    && rm -rf /var/cache/yum \
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

FROM builder as final

MAINTAINER Technology Services, University of Illinois Urbana

COPY --from=modjk /usr/lib64/httpd/modules/mod_jk.so /usr/lib64/httpd/modules/
COPY dereflinks /usr/local/bin/
COPY make_layers.sh manifest.* /tmp/

WORKDIR /tmp
RUN ./make_layers.sh

######################################

FROM scratch

COPY --from=final /tmp/fakeroot/ /
