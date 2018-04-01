FROM       nginx:alpine

MAINTAINER Michael Clausen <encodeering@gmail.com>

EXPOSE     80
EXPOSE     443

ENV        VHOST=ssl-redirect
ENV        NGINX_CONFDIR=/etc/nginx

WORKDIR    ${NGINX_CONFDIR}

RUN        mkdir  conf-available.d conf-global.d \
 &&        rm -rf conf.d/*

COPY       bin/docker-entrypoint.sh /usr/local/bin/

RUN        chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR    /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]

CMD        ["-g", "daemon off;"]
