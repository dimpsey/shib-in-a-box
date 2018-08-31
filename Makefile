.PHONY: all

all: .drone.yml.sig

cron:
	docker build -f Dockerfile.cron -t cron .
	docker run -it --rm -v $(HOME)/.aws:/root/.aws:ro cron

shibd:
	docker build -f Dockerfile.shibd -t shibd .
	docker run -it --rm shibd
 
.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@
