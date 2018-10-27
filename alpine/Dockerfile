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

RUN        apk --no-cache fetch -q --stdout nginx-mod-http-headers-more | tar -xvz -C / --exclude '.*'

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
