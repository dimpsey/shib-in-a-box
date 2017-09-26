FROM httpd:2.4

MAINTAINER Technology Services, University of Illinois Urbana

RUN apt-get update && apt-get install -y -t jessie-backports \
       libapache2-mod-shib2 \
    && rm -rf /var/lib/apt/lists/* 

COPY entrypoint-httpd.sh /usr/local/bin/
COPY shibboleth2.xml.httpd /etc/shibboleth/shibboleth2.xml
COPY shibboleth/ /etc/shibboleth/
COPY httpd.conf /usr/local/apache2/conf/

# TODO: [X] ports 
EXPOSE 8080

# TODO: [ ] split shibd & apache

CMD ["entrypoint-httpd.sh"]