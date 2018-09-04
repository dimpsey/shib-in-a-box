.PHONY: all

all: .drone.yml.sig base get-sealer-keys/get-sealer-keys

cron: get-sealer-keys/get-sealer-keys
	docker build -f Dockerfile.cron -t cron .
	docker run -it -e SECRET_ID --rm -v $(HOME)/.aws:/root/.aws:ro cron

base:
	docker build -f Dockerfile -t shib_base .

shibd: base
	docker build -f Dockerfile.shibd -t shibd .
	docker run -it --rm shibd
 
httpd: base
	docker build -f Dockerfile.httpd -t httpd .
	docker run -it --rm httpd

get-sealer-keys/get-sealer-keys: get-sealer-keys/get-sealer-keys.go
	make -C get-sealer-keys

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

clean:
	-docker rmi cron shib_base shibd httpd
	-rm -f get-sealer-keys/get-sealer-keys
