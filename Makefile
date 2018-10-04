.PHONY: all base cron shibd httpd login push pull clean

BASE_SRCS := Dockerfile $(wildcard yum/*) $(wildcard shibboleth/*)
CRON_SRCS := .base Dockerfile.cron get-sealer-keys/get-sealer-keys.go get-sealer-keys/Makefile
SHIBD_SRCS := .base Dockerfile.shibd get-shib-keys/Makefile get-shib-keys/get-shib-keys.go entrypoint-shibd.sh shibboleth2.xml.shibd
HTTPD_SRCS := .base Dockerfile.httpd test-httpd.sh entrypoint-httpd.sh shibboleth2.xml.httpd $(wildcard httpd/*) $(wildcard environment/*)

all: base cron shibd httpd .drone.yml.sig

base: .base
.base: $(BASE_SRCS)
	docker build -f Dockerfile -t techservicesillinois/shibd-base .
	@touch $@

cron: .cron
.cron: $(CRON_SRCS)
	docker build -f Dockerfile.cron -t techservicesillinois/shib-data-sealer .
	@touch $@

shibd: .shibd
.shibd: $(SHIBD_SRCS)
	docker build -f Dockerfile.shibd -t techservicesillinois/shibd .
	@touch $@

httpd: .httpd
.httpd: $(HTTPD_SRCS)
	docker build -f Dockerfile.httpd -t techservicesillinois/httpd .
	@touch $@

login:
	docker login

push: .push.base .push.cron .push.shibd .push.httpd

.push.base: .base
	docker push techservicesillinois/shibd-base
	@touch $@

.push.cron: .cron
	docker push techservicesillinois/shib-data-sealer
	@touch $@

.push.shibd: .shibd
	docker push techservicesillinois/shibd
	@touch $@

.push.httpd: .httpd
	docker push techservicesillinois/httpd
	@touch $@

pull:
	docker pull techservicesillinois/shibd-base
	docker pull techservicesillinois/shib-data-sealer
	docker pull techservicesillinois/shibd
	docker pull techservicesillinois/httpd

test:
	@-rm -f cookie.txt
	curl -s 127.0.0.1 | grep -s "Hello world"
	! curl -s http://127.0.0.1/Shibboleth.sso/Metadata | diff -q - Metadata.default
	curl -sS -o /dev/null -I -w "%{http_code}" http://127.0.0.1/auth/Shibboleth.sso/Metadata | grep -q 200
	curl -s http://127.0.0.1/auth/Shibboleth.sso/Metadata | diff -q - Metadata.auth
	curl -sS -o /dev/null -ILc cookie.txt -w "%{http_code}" http://127.0.0.1/elmrsample/attributes | grep -q 200
	curl -sILb cookie.txt http://127.0.0.1/elmrsample/logout | grep -q 200   
	curl -sLH "X-Forwarded-Proto: https" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443" 127.0.0.1/cgi-bin/ | grep -q "Shibboleth has encountered an error"
	curl -s localhost/auth/elmr/config | grep -q 302
	docker-compose logs httpd | grep -q 1.2.3.4

	# following two tests with http won't work until we figure out how to set ServerName in httpd.conf
	# dynamically 
	# curl -s 127.0.0.1/cgi-bin/ | grep -q 302
	# curl -sLH "X-Forwarded-Proto: http" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443" 127.0.0.1/cgi-bin/ | grep -q 302

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

clean:
	-docker rmi techservicesillinois/shib-data-sealer \
        techservicesillinois/shibd-base techservicesillinois/shibd \
        techservicesillinois/httpd
	-rm -f .base .cron .shibd .httpd cookie.txt
