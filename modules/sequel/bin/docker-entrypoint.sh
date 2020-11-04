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

upstream () {
    local source="${NGINX_CONFDIR}/upstream.json"
    local file="${NGINX_CONFDIR}/conf-application.d/upstream.conf"

    [ -f "${source}" ] || return 0

    upstreamconfig () {
        local var="${1}"
        local hostname="${2}"
        local port="${3}"

        if [   "${port}" == "null" ]; then
            unset port
        fi

        echo "set \$${var} `getent ahostsv4 "${hostname}" | awk '{ print $1 }' | head -n 1`${port+:}${port};"
    }

    export -f upstreamconfig

    echo -n > "${file}"

    # [{"var":"php","hostname":"php","port":9000},{"var":"redis","hostname":"$REDISHOST"}]
    envsubst < "${source}" | jq -r '.[] | "upstreamconfig \(.var|@sh) \(.hostname|@sh) \(.port|@sh)"' | xargs -I{} bash -c {} >> "${file}"

    unset     upstreamconfig
}

base
canonical
customization
upstream

exec nginx "$@"
