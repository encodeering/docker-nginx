FROM       nginx:alpine AS modules

ARG        MOD_HEADERS_URL=https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz

WORKDIR    /usr/local/src

RUN        apk add coreutils grep gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg1 libxslt-dev gd-dev geoip-dev
RUN        mkdir nginx nginx-headers-more
RUN        curl -L ${MOD_HEADERS_URL} | tar -C nginx-headers-more --strip-components=1 -xvzf -
RUN        curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip-components=1 -xvzf -

WORKDIR    /usr/local/src/nginx

RUN        ./configure --add-dynamic-module=../nginx-headers-more `2>&1 nginx -V | grep -oP '(?<=configure arguments: ).*'`
RUN        make modules
RUN        cp -npv objs/*.so /etc/nginx/modules
RUN        find /etc/nginx/modules/ -iname '*module.so' -exec sh -c 'echo $1; sed -i "1i load_module modules/`basename $1`\;" /etc/nginx/nginx.conf' -- {} \;
RUN        nginx -t


FROM       nginx:alpine

MAINTAINER Michael Clausen <encodeering@gmail.com>

EXPOSE     80
EXPOSE     443

ENV        VHOST=ssl-redirect
ENV        NGINX_CONFDIR=/etc/nginx

WORKDIR    ${NGINX_CONFDIR}

RUN        deluser                 xfs               \
 &&        addgroup -g 33 -S       www-data          \
 &&        adduser  -u 33 -D -S -G www-data www-data

COPY       --from=modules /etc/nginx/modules /etc/nginx/modules

RUN        mkdir  conf-available.d conf-global.d \
 &&        rm -rf conf.d/*

COPY       nginx/nginx.conf   .
COPY       nginx/vconf/*.conf conf-global.d/
COPY       nginx/vhost/*.conf conf-available.d/
COPY       nginx/vhost/conf   conf

COPY       bin/docker-entrypoint.sh /usr/local/bin/

RUN        chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR    /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]

CMD        ["-g", "daemon off;"]
