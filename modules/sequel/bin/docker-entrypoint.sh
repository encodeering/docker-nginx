#!/usr/bin/env bash

set -e
set -o pipefail

NGINX_VHOST="${NGINX_CONFDIR}/conf.d/vhost.conf"

die () {
    echo "$1"
    exit 1
}

base () {
    local   file="${NGINX_CONFDIR}/conf-available.d/${VHOST}.conf"

    [ -f "${file}" ] || die "vhost ${VHOST} not available"

    cat  "${file}" > "${NGINX_VHOST}"
}

canonical () {
    local listen=`cat "${NGINX_VHOST}" | grep -oE '^.*listen.*$' | tail -n2 | tr '\n' '@'`
    local file="${NGINX_CONFDIR}/conf-available.d/trait/${VHOST_CANONICAL}.conf"

    [ -z "${VHOST_CANONICAL}" ] && return 0
    [ -f "${file}" ] || die "canonical trait ${VHOST_CANONICAL} not available"

    cat  "${file}" | sed -e "s/^.*{{LISTEN}}$/${listen}/g;s/@/\n/g" >> "${NGINX_VHOST}"
}

customization () {
    [ "${VHOST_CUSTOMIZATION}" = "true" ] && {
        mkdir -p             nginx;
        chown nginx:www-data nginx || die "chown couldn't be applied";
        chmod 750            nginx || die "chmod couldn't be applied";
    } || {
        sed -i -e '/customization.conf;$/d' "${NGINX_VHOST}";
    }
}

base
canonical
customization

exec nginx "$@"
