FROM httpd:2.4

MAINTAINER Technology Services, University of Illinois Urbana

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu

RUN apt-get update && apt-get install -y -t jessie-backports \
       libapache2-mod-shib2 wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /etc/shibboleth/itrust.pem \
       "${DISCOVERY_SVC_URL}/itrust-certs/itrust.pem" \
    && wget -O /etc/shibboleth/itrust-metadata.xml \
       "${DISCOVERY_SVC_URL}/itrust-metadata/itrust-metadata.xml"

COPY entrypoint-httpd.sh /usr/local/bin/
COPY shibboleth2.xml.httpd /etc/shibboleth/shibboleth2.xml
COPY shibboleth/ /etc/shibboleth/
COPY apache2/ /usr/local/apache2/conf/
COPY environment /usr/local/apache2/cgi-bin/

RUN chmod 600 /usr/local/apache2/conf/server.crt \
      /usr/local/apache2/conf/server.key \
      /etc/shibboleth/sp-cert.pem \
      /etc/shibboleth/sp-key.pem \
      /etc/shibboleth/itrust.pem \
      /etc/shibboleth/itrust-metadata.xml \
    && chmod 755 /usr/local/apache2/cgi-bin/environment

EXPOSE 8080 8443

CMD ["entrypoint-httpd.sh"]
