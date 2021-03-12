ARG alpine_ver=3.13.2
FROM alpine:$alpine_ver AS builder
ARG nginxver=1.19.7
ARG nchan_ver=1.2.7
ARG redis_ver=0.3.9

LABEL maintainer="Edward Finlayson <technoboggle@lasermail.co.uk>" \
  version="1.0.0" \
  description="This docker image is built as a super small nginx \
microservice which has edge states available which \
provide connectors for socket.io style applications \
and also secure headers, Redis conectivity for session \
redirections and PCRE compliane regular expresssions."

RUN apk update

# nginx:alpine contains NGINX_VERSION environment variable, like so:
#ENV nginx_ver "$nginx_ver"

# Our NCHAN version
#ENV NCHAN_VERSION "$nchan_ver"

# Our HTTP Redis version
#ENV HTTP_REDIS_VERSION "$redis_ver"
RUN echo "http://nginx.org/download/nginx-$nginxver.tar.gz"
# Download sources
RUN mkdir -p /usr/src && \
    cd /usr/src && \
    wget "http://nginx.org/download/nginx-${nginxver}.tar.gz" -O nginx.tar.gz && \
    wget "https://github.com/slact/nchan/archive/v${nchan_ver}.tar.gz" -O nchan.tar.gz && \
    wget "https://people.freebsd.org/~osa/ngx_http_redis-${redis_ver}.tar.gz" -O http_redis.tar.gz && \
    wget "https://github.com/GetPageSpeed/ngx_security_headers/archive/master.tar.gz" -O ngx_security_headers.tar.gz && \
    wget "https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz" -O pcre.tar.gz

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
  geoip-dev
# Following switch removed as invalid on Alpine -fomit-frame-pointer
RUN CONFARGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os' --with-ld-opt=-Wl,--as-needed"

# Reuse same cli arguments as the nginx:alpine image used to build
# RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \ 
RUN cd /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nchan.tar.gz" && \
  sed -i 's/uint16_t  memstore_worker_generation/extern uint16_t  memstore_worker_generation/g' "nchan-${nchan_ver}/src/store/memory/store-private.h" && \
  sed -i 's/redis_lua_scripts_t redis_lua_scripts/extern redis_lua_scripts_t redis_lua_scripts/g' "nchan-${nchan_ver}/src/store/redis/redis_lua_commands.h" && \
  sed -i 's/const int redis_lua_scripts_count/extern const int redis_lua_scripts_count/g' "nchan-${nchan_ver}/src/store/redis/redis_lua_commands.h" && \
  tar -xzvf "http_redis.tar.gz" && \
  tar -xzvf "pcre.tar.gz" && \
  tar -xzvf "ngx_security_headers.tar.gz" && \
  NCHANDIR="$(pwd)/nchan-${nchan_ver}" && \
  HTTP_REDIS_DIR="$(pwd)/ngx_http_redis-${redis_ver}" && \
  SEC_HEADERS_DIR="$(pwd)/ngx_security_headers-master" && \
  cd /usr/src/nginx-$nginxver && \
  ./configure --with-compat $CONFARGS --with-http_gzip_static_module --add-dynamic-module=$NCHANDIR --add-dynamic-module=$HTTP_REDIS_DIR --add-dynamic-module=$SEC_HEADERS_DIR && \
  make modules && \
  mv ./objs/*.so /


#  make && make install

FROM nginx:1.19.7-alpine

RUN apk update
RUN apk add bash
# Extract the dynamic module NCHAN from the builder image
COPY --from=builder /ngx_nchan_module.so /usr/local/nginx/modules/ngx_nchan_module.so
# Extract the dynamic module HTTP_REDIS from the builder image
COPY --from=builder /ngx_http_redis_module.so /usr/local/nginx/modules/ngx_http_redis_module.so
# Extract the dynamic module ngx_security_headers from the builder image
COPY --from=builder /ngx_http_security_headers_module.so /usr/local/nginx/modules/ngx_http_security_headers_module.so

#RUN rm /etc/nginx/conf.d/default.conf
RUN mkdir -p /usr/parent
#COPY web_assets/ /usr/share/nginx/html/

#COPY nginx.conf /etc/nginx/nginx.conf
#COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
