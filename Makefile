.PHONY: all builder base common cron http-status shibd httpd login push pull clean

MAKEFLAGS='-j 4'

export ORG := techservicesillinois/

all: config cron shibd httpd .drone.yml.sig

builder:
	make -C $@

base: builder
	make -C $@

common: base
	make -C $@

config: base
	make -C $@

cron:
	make -C $@

shibd: common
	make -C $@

httpd: common http-status
	make -C $@

http-status:
	make -C $@ image

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
	$(HTTP_CODE_CURL) $(ELMR_LOGOUT)  | $(500) # Should this be a 401?
	$(HTTP_CODE_CURL) $(APP_LOGOUT)   | $(302) # Should this be a 401?
	# Test that the client's IP is logged not the LB's!
	curl -o /dev/null -sLH "X-Forwarded-Proto: https" -H "X-Forwarded-For: 1.2.3.4" -H "X-Forwarded-Port: 443" 127.0.0.1
	docker-compose logs httpd | grep -q 1.2.3.4
	#
	# Test redirects - Do we want to test this? Should config be disabled by
	# default?
	# $(REDIRECT_CURL) http://127.0.0.1/elmrsample/config | $(REDIRECT_TEST)
	# $(REDIRECT_CURL) http://127.0.0.1/auth/elmr/config | $(REDIRECT_TEST)

.drone.yml.sig: .drone.yml
	drone sign cites-illinois/illinois-shibboleth-sp-img
	git add $^ $@

clean:
	make clean -C config
	make clean -C cron
	make clean -C httpd
	make clean -C shibd
	make clean -C common
	make clean -C base
	make clean -C builder
	make clean -C http-status
	-rm -f cookie.txt
