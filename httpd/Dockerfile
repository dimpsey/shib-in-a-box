FROM techservicesillinois/httpd-shibd-common

ENV SHIBSP_CONFIG=/var/run/httpd/shibboleth2.xml

COPY entrypoint-httpd.sh /usr/local/bin/
COPY --from=techservicesillinois/http-status /healthcheck /

USER apache
EXPOSE 8080 

# TODO This should be config be pulled from config!
# TODO will need to add the option to configure healthcheck with a
#      file
HEALTHCHECK CMD /healthcheck \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Metadata \
    -c 200 http://localhost:8080/auth/Shibboleth.sso/Status \
    -c 204 http://localhost:8080/auth/elmr/status

ENTRYPOINT ["entrypoint-httpd.sh"]
