.PHONY: all base cron shibd httpd login push pull clean

all: base cron shibd httpd .drone.yml.sig

base:
	docker build -f Dockerfile -t techservicesillinois/shibd-base .

cron: base get-sealer-keys/get-sealer-keys
	docker build -f Dockerfile.cron -t techservicesillinois/shib-data-sealer .

shibd: base get-shib-keys/get-shib-keys
	docker build -f Dockerfile.shibd -t techservicesillinois/shibd .

httpd: base
	docker build -f Dockerfile.httpd -t techservicesillinois/httpd .
	
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
	make -C get-sealer-keys clean
	make -C get-shib-keys clean
