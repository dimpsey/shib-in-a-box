IMAGES := builder base common config cron shibd httpd healthcheck
CLEAN := $(addsuffix .clean,$(IMAGES))
.PHONY: all login push pull clean $(IMAGES)

MAKEFLAGS='-j 4'

export TAG := local
export SHIB_IN_A_BOX_TAG := $(TAG)

all: $(IMAGES) .drone.yml.sig

up: all
	docker-compose up -d

reload: down all
	docker-compose up -d

down:
	docker-compose down

base: builder
config: base
common: base
shibd: common
httpd: common healthcheck

$(IMAGES):
	make -C $@

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

builder.clean: base.clean
base.clean: common.clean config.clean
common.clean: shibd.clean httpd.clean

clean: $(CLEAN)
	-rm -f cookie.txt

%.clean:
	make clean -C $*

login:
	docker login

push: .push.base .push.cron .push.shibd .push.config .push.httpd

.push.base: base
	docker push techservicesillinois/shibd-base
	@touch $@

.push.cron: cron
	docker push techservicesillinois/shibd-cron
	@touch $@

.push.shibd: shibd
	docker push techservicesillinois/shibd
	@touch $@

.push.config: config
	docker push techservicesillinois/shibd-config
	@touch $@

.push.httpd: httpd
	docker push techservicesillinois/httpd
	@touch $@

pull:
	docker pull techservicesillinois/shibd-base
	docker pull techservicesillinois/shibd-cron
	docker pull techservicesillinois/shibd
	docker pull techservicesillinois/httpd

CURL=curl -sS -o /dev/null
REDIRECT_CURL=$(CURL) -b cookie.txt -c cookie.txt -w "%{http_code} %{redirect_url}"
HTTP_CODE_CURL=$(CURL) -w "%{http_code}"
COOKIE_CURL=$(REDIRECT_CURL) -c cookie.txt

ELMR_SESSION=http://127.0.0.1/auth/elmr/session
ELMR_LOGOUT=http://127.0.0.1/auth/elmr/session?mode=logout
SHIB_LOGOUT=http://127.0.0.1/auth/Shibboleth.sso/Logout

APP_ATTRIB=http://127.0.0.1/elmrsample/attributes
APP_LOGOUT=http://127.0.0.1/elmrsample/logout

# Internal Server Error
500=grep -q 500

# Forbidden
403=grep -q 403

# Bad Request
400=grep -q 400

# Redirect
302=grep -q 302

# OK
200=grep -q 200

test:
	# Expect no content at /
	$(HTTP_CODE_CURL) http://127.0.0.1 | $(403)
	# Make sure no welcome page is returned!
	! curl -sS http://127.0.0.1 | grep 'Testing 123'
	#
	# Check Shibboleth Metadata is correct
	$(HTTP_CODE_CURL) http://127.0.0.1/auth/Shibboleth.sso/Metadata | $(200)
	! curl -sS http://127.0.0.1/Shibboleth.sso/Metadata | diff -q - Metadata.default
	curl -sS http://127.0.0.1/auth/Shibboleth.sso/Metadata | diff -q - Metadata.auth
	$(HTTP_CODE_CURL) http://localhost/auth/shibboleth-sp/main.css | $(200)
	#
	# Check elmrsample works
	@-rm -f cookie.txt
	$(REDIRECT_CURL) $(APP_ATTRIB)   | grep -q "302 $(ELMR_SESSION)"
	$(REDIRECT_CURL) $(ELMR_SESSION) | grep -q "302 $(APP_ATTRIB)"
	$(REDIRECT_CURL) $(APP_ATTRIB)   | $(200)
	# test logout
	$(REDIRECT_CURL) $(APP_LOGOUT)   | grep -q "302 $(ELMR_LOGOUT)"
	$(REDIRECT_CURL) $(ELMR_LOGOUT)  | grep -q "302 $(SHIB_LOGOUT)"
	$(REDIRECT_CURL) $(SHIB_LOGOUT)  | $(200)
	# Let's make sure we really are logged out!
	$(REDIRECT_CURL) $(APP_ATTRIB)   | grep -q "302 $(ELMR_SESSION)"
	# TODO - This seems like a bug. Should we be able to logout twice?
	$(REDIRECT_CURL) $(APP_LOGOUT)   | grep -q "302 $(ELMR_LOGOUT)"  # Should this be a 400 or 401?
	#
	# Tests with no cookies
	@-rm -f cookie.txt
	$(HTTP_CODE_CURL) $(ELMR_SESSION) | $(400)
	$(HTTP_CODE_CURL) $(ELMR_LOGOUT)  | $(302)
	$(HTTP_CODE_CURL) $(APP_LOGOUT)   | $(302)
	# Test that the client's IP is logged not the LB's!
	curl -o /dev/null -sLH "X-Forwarded-Proto: https" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443" 127.0.0.1
	docker-compose logs httpd | grep -q 1.2.3.4
	#
	# Test redirects - Do we want to test this? Should config be disabled by
	# default?
	# $(REDIRECT_CURL) http://127.0.0.1/elmrsample/config | $(302)
	# $(REDIRECT_CURL) http://127.0.0.1/auth/elmr/config | $(302)
	$(HTTP_CODE_CURL) http://127.0.0.1/auth/elmr/config | $(200)
