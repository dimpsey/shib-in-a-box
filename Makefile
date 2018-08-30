.PHONY: all

all: .drone.yml.sig

cron:
	docker build -f Dockerfile.cron -t cron .
	docker run -it --rm -v $(HOME)/.aws:/root/.aws:ro cron

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@
