#!/usr/bin/env bash

set -e
set -o pipefail

if [ `find ${NGINX_CONFDIR}/conf.d ! -name "${VHOST}.*" -type l | wc -l` -gt 0 ]; then
    echo "error: a vhost has already been enabled - VHOST envvar should be treated as effectively immutable"
    exit 1
fi

ln -s ${NGINX_CONFDIR}/conf-available.d/${VHOST}.conf ${NGINX_CONFDIR}/conf.d || true

exec nginx "$@"
