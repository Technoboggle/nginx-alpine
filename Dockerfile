FROM alpine:3.14.2 AS builder
LABEL maintainer="Edward Finlayson <technoboggle@lasermail.co.uk>" \
  version="1.0.0" \
  description="This docker image is built as a super small nginx \
microservice which has edge states available which \
provide connectors for socket.io style applications \
and also secure headers, Redis conectivity for session \
redirections and PCRE compliane regular expresssions."

RUN apk --no-cache update

# nginx:alpine contains NGINX_VERSION environment variable, like so:
ENV NGINX_VERSION 1.21.3

# Our NCHAN version
ENV NCHAN_VERSION 1.2.12

# Our HTTP Redis version
ENV HTTP_REDIS_VERSION 0.3.9

# Our nginx security headers version
ENV NGX_SEC_HEADER 0.0.9

# Our nginx security headers version
ENV PCRE_VERSION 8.45

# User credentials nginx to run as
ENV USER_ID=82 \
    GROUP_ID=82 \
    USER_NAME=www-data \
    GROUP_NAME=www-data 


# Download sources
RUN apk --no-cache upgrade musl && \
    apk add --no-cache shadow && \
    mkdir -p /usr/src && \
    cd /usr/src && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    wget "https://github.com/slact/nchan/archive/v${NCHAN_VERSION}.tar.gz" -O nchan.tar.gz && \
    wget "https://people.freebsd.org/~osa/ngx_http_redis-${HTTP_REDIS_VERSION}.tar.gz" -O http_redis.tar.gz && \
    wget "https://github.com/GetPageSpeed/ngx_security_headers/archive/refs/tags/${NGX_SEC_HEADER}.tar.gz" -O ngx_security_headers.tar.gz && \
    wget "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz" -O pcre.tar.gz

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  sed \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev && \
  (deluser "${USER_NAME}" || true) && \
  (delgroup "${GROUP_NAME}" || true) && \
  groupadd -r -g "$GROUP_ID" "$GROUP_NAME" && \
  useradd -r -u "$USER_ID" -g "$GROUP_ID" -c "$GROUP_NAME" -d /srv/www -s /sbin/nologin "$USER_NAME" && \
# Following switch removed as invalid on Alpine -fomit-frame-pointer
  CONFARGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=$USER_NAME --group=$GROUP_NAME --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os' --with-ld-opt=-Wl,--as-needed "

# Reuse same cli arguments as the nginx:alpine image used to build
RUN cd /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nchan.tar.gz" && \
  tar -xzvf "http_redis.tar.gz" && \
  tar -xzvf "pcre.tar.gz" && \
  tar -xzvf "ngx_security_headers.tar.gz" && \
  NCHANDIR="$(pwd)/nchan-${NCHAN_VERSION}" && \
  HTTP_REDIS_DIR="$(pwd)/ngx_http_redis-${HTTP_REDIS_VERSION}" && \
  SEC_HEADERS_DIR="$(pwd)/ngx_security_headers-${NGX_SEC_HEADER}" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  CFLAGS="-fcommon" \
  ./configure --with-compat $CONFARGS --with-http_gzip_static_module --add-dynamic-module=$NCHANDIR --add-dynamic-module=$HTTP_REDIS_DIR --add-dynamic-module=$SEC_HEADERS_DIR && \
  make modules && \
  mv ./objs/*.so /


#  make && make install

FROM nginx:1.21.3-alpine
ENV USER_ID=82 \
    GROUP_ID=82 \
    USER_NAME=www-data \
    GROUP_NAME=www-data

RUN apk upgrade --no-cache musl && \
    apk update --no-cache && \
    apk add --no-cache bash shadow
#    apk add --no-cache openssl && \
#    wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.tgz -O /usr/local/bin/ngrok.tgz && \
#    cd /usr/local/bin/ && \
#    tar -xvzf ngrok.tgz && \
#    rm -f ngrok.tgz && \
#    if [ ! -d "/root/.ngrok2" ]; then \
#      mkdir /root/.ngrok2; \
#    fi; \
##    groupadd -r -g "$GROUP_ID" "$GROUP_NAME" && \
#    useradd -r -u "$USER_ID" -g "$GROUP_ID" -c "$GROUP_NAME" -d /srv/www -s /sbin/nologin "$USER_NAME"


#COPY /ngrok.yml /root/.ngrok2/
# Extract the dynamic module NCHAN from the builder image   -fcommon
COPY --from=builder /ngx_nchan_module.so /usr/local/nginx/modules/ngx_nchan_module.so
# Extract the dynamic module HTTP_REDIS from the builder image
COPY --from=builder /ngx_http_redis_module.so /usr/local/nginx/modules/ngx_http_redis_module.so
# Extract the dynamic module ngx_security_headers from the builder image
COPY --from=builder /ngx_http_security_headers_module.so /usr/local/nginx/modules/ngx_http_security_headers_module.so
RUN apk update; \
    apk add --upgrade libjpeg-turbo;
WORKDIR /srv/www
EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
