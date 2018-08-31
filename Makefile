.PHONY: all

all: .drone.yml.sig

cron:
	docker build -f Dockerfile.cron -t cron .
	docker run -it --rm -v $(HOME)/.aws:/root/.aws:ro cron

base:
	docker build -f Dockerfile -t shib_base .

shibd: base
	docker build -f Dockerfile.shibd -t shibd .
	docker run -it --rm shibd
 
httpd: base
	docker build -f Dockerfile.httpd -t httpd .
	docker run -it --rm httpd

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@
