#!/bin/bash
echo "Configuration & Restart NGINX"

mkdir -p /var/cache/nginx
chown nginx:nginx /var/cache/nginx

if [ -f /usr/parent/conf/nginx.conf ]; then
  echo "Copying main config file to container"
  cp /usr/parent/conf/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f /usr/parent/conf/default.conf ]; then
  echo "Copying server config file to container"
  cp /usr/parent/conf/default.conf /etc/nginx/conf.d/default.conf
fi

#if [ ! -L /tmp/php ]; then
#  ln -s /shared/cache/php /tmp/php
#fi

nginx -g "daemon off;"

exec "$@"
