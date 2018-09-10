.PHONY: all

all: .drone.yml.sig base get-sealer-keys/get-sealer-keys get-shib-keys/get-shib-keys

cron: get-sealer-keys/get-sealer-keys
	docker build -f Dockerfile.cron -t cron .
	docker run -it -e SECRET_ID -e SCHEDULE='* * * * *' --rm -v $(HOME)/.aws:/var/run/shibboleth/.aws:ro cron

base:
	docker build -f Dockerfile -t shib_base .

shibd: base get-shib-keys/get-shib-keys
	docker build -f Dockerfile.shibd -t shibd .
	docker run -it --rm -v $(HOME)/.aws:/root/.aws:ro shibd
 
httpd: base
	docker build -f Dockerfile.httpd -t httpd .
	docker run -it --rm httpd

get-sealer-keys/get-sealer-keys: get-sealer-keys/get-sealer-keys.go
	make -C get-sealer-keys

get-shib-keys/get-shib-keys: get-shib-keys/get-shib-keys.go
	make -C get-shib-keys

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

clean:
	-docker rmi cron shib_base shibd httpd
	make -C get-sealer-keys clean
	make -C get-shib-keys clean
