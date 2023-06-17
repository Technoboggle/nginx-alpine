FROM alpine:3.17.1 AS builder
LABEL maintainer="Edward Finlayson <technoboggle@lasermail.co.uk>" \
  version="1.0.0" \
  description="This docker image is built as a super small nginx \
microservice which has edge states available which \
provide connectors for socket.io style applications \
and also secure headers, Redis conectivity for session \
redirections and PCRE compliane regular expresssions."

# Technoboggle Build time arguments.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="Technoboggle/nginx-alpine"
LABEL org.label-schema.description="Technoboggle lightweight Redis node"
LABEL org.label-schema.url="http://technoboggle.com/"
LABEL org.label-schema.vcs-url="https://github.com/Technoboggle/nginx-alpine"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="WSO2"
LABEL org.label-schema.version=$BUILD_VERSION


RUN apk --no-cache update

ARG ALPINE_VERSION=3.17.1

# nginx:alpine contains NGINX_VERSION environment variable, like so:
ARG NGINX_VERSION=1.21.6
## When last tried (21/07/2022) nginx versions above 1.21.6 (including 1.23.3) would not allow the redis module to compile due to changes in ngx_http_upstream.h and others

# Our NCHAN version
ARG NCHAN_VERSION=1.3.6

# Our HTTP Redis version
ARG HTTP_REDIS_VERSION=0.3.9

ARG REDIS2_NGINX=0.15

# Our nginx security headers version
ARG NGX_SEC_HEADER=0.0.11

# Our nginx security headers version
ARG PCRE_VERSION=8.45
# Our nginx mod_zip version
ARG MOD_ZIP_VERSION=1.2.0

# User credentials nginx to run as
ARG USER_ID=82 \
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
  wget "https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v${REDIS2_NGINX}.tar.gz" -O redis2.tar.gz && \
  wget "https://github.com/GetPageSpeed/ngx_security_headers/archive/refs/tags/${NGX_SEC_HEADER}.tar.gz" -O ngx_security_headers.tar.gz && \
  wget "http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz"  -O pcre.tar.gz && \
  wget "https://github.com/evanmiller/mod_zip/archive/refs/tags/${MOD_ZIP_VERSION}.tar.gz" -O mod_zip.tar.gz && \

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
  apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  sed \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  libcurl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev && \
  apk upgrade --no-cache musl curl libcurl&& \
  (deluser "${USER_NAME}" || true) && \
  (delgroup "${GROUP_NAME}" || true) && \
  groupadd -r -g "$GROUP_ID" "$GROUP_NAME" && \
  useradd -r -u "$USER_ID" -g "$GROUP_ID" -c "$GROUP_NAME" -d /srv/www -s /sbin/nologin "$USER_NAME" && \
# Following switch removed as invalid on Alpine -fomit-frame-pointer
  CONFARGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=$USER_NAME --group=$GROUP_NAME --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os' --with-ld-opt=-Wl,--as-needed " && \

# Reuse same cli arguments as the nginx:alpine image used to build
  cd /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nchan.tar.gz" && \
  tar -xzvf "http_redis.tar.gz" && \
  tar -xvzf "redis2.tar.gz" && \
  tar -xzvf "pcre.tar.gz" && \
  tar -xzvf "ngx_security_headers.tar.gz" && \
  tar -xzvf "mod_zip.tar.gz" && \
  NCHANDIR="$(pwd)/nchan-${NCHAN_VERSION}" && \
  HTTP_REDIS_DIR="$(pwd)/ngx_http_redis-${HTTP_REDIS_VERSION}" && \
  REDIS2_NGINX_DIR="$(pwd)/redis2-nginx-module-${REDIS2_NGINX}" && \
  SEC_HEADERS_DIR="$(pwd)/ngx_security_headers-${NGX_SEC_HEADER}" && \
  MOD_ZIP_DIR="$(pwd)/mod_zip-${MOD_ZIP_VERSION}" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  CFLAGS="-fcommon" \
  ./configure --with-compat $CONFARGS --with-http_gzip_static_module --add-dynamic-module=$NCHANDIR --add-dynamic-module=$HTTP_REDIS_DIR --add-dynamic-module=$REDIS2_NGINX_DIR --add-dynamic-module=$SEC_HEADERS_DIR --add-dynamic-module=$MOD_ZIP_DIR && \
  make modules && \
  mv ./objs/*.so / && \
  ls -al /


#  make && make install

FROM nginx:1.25.1-alpine
ENV USER_ID=82 \
    GROUP_ID=82 \
    USER_NAME=www-data \
    GROUP_NAME=www-data

RUN apk upgrade --no-cache musl curl libcurl&& \
    apk update --no-cache && \
    apk add --no-cache bash shadow libjpeg-turbo;
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

# Extract the dynamic modules from the builder image above and place in lightweight image for execution
COPY --from=builder /*.so /usr/local/nginx/modules/

#RUN apk update; \
#    apk add --upgrade libjpeg-turbo;
WORKDIR /srv/www
EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
