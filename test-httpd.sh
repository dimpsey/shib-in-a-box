#!/bin/bash

set -e

status_is() {
    echo $1
    curl -sS -o /dev/stderr -I -w "%{http_code}" $1 | grep -q $2 || exit 1
}

status_is http://localhost:8080/auth/Shibboleth.sso/Status 200
status_is http://localhost:8080/auth/Shibboleth.sso/Metadata 200
# TODO Add a test for elmr!
