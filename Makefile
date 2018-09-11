.PHONY: all base cron shibd httpd login push pull clean

BASE_SRCS := Dockerfile $(wildcard yum/*) $(wildcard shibboleth/*)
CRON_SRCS := .base Dockerfile.cron get-sealer-keys/get-sealer-keys entrypoint-cron.sh
SHIBD_SRCS := .base Dockerfile.shibd get-shib-keys/get-shib-keys entrypoint-shibd.sh shibboleth2.xml.shibd
HTTPD_SRCS := .base Dockerfile.httpd entrypoint-httpd.sh shibboleth2.xml.httpd $(wildcard httpd/*) $(wildcard environment/*)

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

get-sealer-keys/get-sealer-keys: get-sealer-keys/get-sealer-keys.go
	make -C get-sealer-keys

get-shib-keys/get-shib-keys: get-shib-keys/get-shib-keys.go
	make -C get-shib-keys

login:
	docker login

push: base cron shibd httpd
	docker push techservicesillinois/shibd-base
	docker push techservicesillinois/shib-data-sealer
	docker push techservicesillinois/shibd
	docker push techservicesillinois/httpd

pull:
	docker pull techservicesillinois/shibd-base
	docker pull techservicesillinois/shib-data-sealer
	docker pull techservicesillinois/shibd
	docker pull techservicesillinois/httpd

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

clean:
	-docker rmi techservicesillinois/shib-data-sealer \
        techservicesillinois/shibd-base techservicesillinois/shibd \
        techservicesillinois/httpd
	-rm -f .base .cron .shibd .httpd
	make -C get-sealer-keys clean
	make -C get-shib-keys clean
