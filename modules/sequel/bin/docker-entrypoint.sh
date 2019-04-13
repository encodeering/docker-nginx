#!/usr/bin/env bash

set -e
set -o pipefail

mkdir -p             nginx
chown nginx:www-data nginx
chmod 750            nginx

NGINX_VHOST="${NGINX_CONFDIR}/conf.d/vhost.conf"

cat "${NGINX_CONFDIR}/conf-available.d/${VHOST}.conf" > "${NGINX_VHOST}"

exec nginx "$@"
