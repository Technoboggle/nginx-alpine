ARG BUILDER_ALPINE_VERSION
ARG BUILDER_NGINX_VERSION
ARG ALPINE_VERSION
ARG NGINX_VERSION
ARG NCHAN_VERSION
ARG HTTP_REDIS_VERSION
ARG REDIS2_NGINX
ARG NGX_SEC_HEADER
ARG PCRE_VERSION
ARG MOD_ZIP_VERSION
ARG SET_MISC_NGINX_MODULE
ARG NGINX_DEVEL_KIT
ARG SRCACHE_NGINX
ARG MAINTAINER_NAME
ARG AUTHORNAME
ARG AUTHORS
ARG VERSION
ARG SCHEMAVERSION
ARG NAME
ARG DESCRIPTION
ARG URL
ARG VCS_URL
ARG VENDOR
ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG DOCKERCMD


FROM alpine:${BUILDER_ALPINE_VERSION} as builder

ARG BUILDER_ALPINE_VERSION
ARG BUILDER_NGINX_VERSION
ARG ALPINE_VERSION
ARG NGINX_VERSION
ARG NCHAN_VERSION
ARG HTTP_REDIS_VERSION
ARG REDIS2_NGINX
ARG NGX_SEC_HEADER
ARG PCRE_VERSION
ARG MOD_ZIP_VERSION
ARG SET_MISC_NGINX_MODULE
ARG NGINX_DEVEL_KIT
ARG SRCACHE_NGINX
ARG MAINTAINER_NAME
ARG AUTHORNAME
ARG AUTHORS
ARG VERSION
ARG SCHEMAVERSION
ARG NAME
ARG DESCRIPTION
ARG URL
ARG VCS_URL
ARG VENDOR
ARG BUILD_VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG DOCKERCMD

LABEL maintainer="Edward Finlayson <technoboggle@lasermail.co.uk>" \
  version="1.0.0" \
  description="This docker image is built as a super small nginx \
microservice which has edge states available which \
provide connectors for socket.io style applications \
and also secure headers, Redis conectivity for session \
redirections and PCRE compliane regular expresssions."

ENV NCHAN_VERSION="${NCHAN_VERSION}"
ENV HTTP_REDIS_VERSION="${HTTP_REDIS_VERSION}"
ENV REDIS2_NGINX="${REDIS2_NGINX}"
ENV NGX_SEC_HEADER="${NGX_SEC_HEADER}"
ENV PCRE_VERSION="${PCRE_VERSION}"
ENV MOD_ZIP_VERSION="${MOD_ZIP_VERSION}"
ENV SET_MISC_NGINX_MODULE="${SET_MISC_NGINX_MODULE}"
ENV NGINX_DEVEL_KIT="${NGINX_DEVEL_KIT}"
ENV SRCACHE_NGINX="${SRCACHE_NGINX}"
ENV MAINTAINER_NAME="${MAINTAINER_NAME}"
ENV AUTHORNAME="${AUTHORNAME}"
ENV AUTHORS="${AUTHORS}"
ENV VERSION="${VERSION}"
ENV SCHEMAVERSION="${SCHEMAVERSION}"
ENV NAME="${NAME}"
ENV DESCRIPTION="${DESCRIPTION}"
ENV URL="${URL}"
ENV VCS_URL="${VCS_URL}"
ENV VENDOR="${VENDOR}"
ENV BUILD_VERSION="${BUILD_VERSION}"
ENV BUILD_DATE="${BUILD_DATE}"
ENV VCS_REF="${VCS_REF}"
ENV DOCKERCMD="${DOCKERCMD}"

# Labels.
LABEL maintainer=${MAINTAINER_NAME} \
    version=${VERSION} \
    description=${DESCRIPTION} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name=${NAME} \
    org.label-schema.description=${DESCRIPTION} \
    org.label-schema.usage=${USAGE} \
    org.label-schema.url=${URL} \
    org.label-schema.vcs-url=${VCS_URL} \
    org.label-schema.vcs-ref=${VSC_REF} \
    org.label-schema.vendor=${VENDOR} \
    org.label-schema.version=${BUILDVERSION} \
    org.label-schema.schema-version=${SCHEMAVERSION} \
    org.label-schema.docker.cmd=${DOCKERCMD} \
    org.label-schema.docker.cmd.devel="" \
    org.label-schema.docker.cmd.test="" \
    org.label-schema.docker.cmd.debug="" \
    org.label-schema.docker.cmd.help="" \
    org.label-schema.docker.params=""

# Create the nginx user and group with the correct UID and GID to match the host
ADD user_fix.sh /usr/local/bin/user_fix.sh
RUN chmod +x /usr/local/bin/user_fix.sh && \
  /usr/local/bin/user_fix.sh && \
  \
  # Download sources
  apk --no-cache update musl && \
  apk add --no-cache linux-pam shadow && \
  mkdir -p /usr/src && \
  cd /usr/src && \
  \
  wget "http://nginx.org/download/nginx-${BUILDER_NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget "https://github.com/slact/nchan/archive/v${NCHAN_VERSION}.tar.gz" -O nchan.tar.gz && \
  wget "https://people.freebsd.org/~osa/ngx_http_redis-${HTTP_REDIS_VERSION}.tar.gz" -O http_redis.tar.gz && \
  wget "https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v${REDIS2_NGINX}.tar.gz" -O redis2.tar.gz && \
  wget "https://github.com/GetPageSpeed/ngx_security_headers/archive/refs/tags/${NGX_SEC_HEADER}.tar.gz" -O ngx_security_headers.tar.gz && \
  wget "http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz"  -O pcre.tar.gz && \
  wget "https://github.com/evanmiller/mod_zip/archive/refs/tags/${MOD_ZIP_VERSION}.tar.gz" -O mod_zip.tar.gz && \
  wget "https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NGINX_DEVEL_KIT}.tar.gz" -O nginx_devel_kit.tar.gz && \
  wget "https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v${SET_MISC_NGINX_MODULE}.tar.gz" -O set-misc-nginx-module.tar.gz && \
  wget "https://github.com/openresty/srcache-nginx-module/archive/refs/tags/v${SRCACHE_NGINX}.tar.gz" -O srcache.tar.gz && \
  \
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
  apk update --no-cache musl curl libcurl && \
  apk add --no-cache --update \
  nghttp2=1.51.0-r2 \
  nghttp2-libs=1.51.0-r2 \
  libx11=1.8.7-r0 \
  tiff=4.4.0-r4 && \
  CONFARGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-perl_modules_path=/usr/lib/perl5/vendor_perl --user=$USER_NAME --group=$GROUP_NAME --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os' --with-ld-opt=-Wl,--as-needed " && \
  cd /usr/src && \
  tar -zxC /usr/src -f nginx.tar.gz && \
  tar -xzvf "nchan.tar.gz" && \
  tar -xzvf "http_redis.tar.gz" && \
  tar -xvzf "redis2.tar.gz" && \
  tar -xzvf "pcre.tar.gz" && \
  tar -xzvf "ngx_security_headers.tar.gz" && \
  tar -xzvf "mod_zip.tar.gz" && \
  \
  tar -xzvf "nginx_devel_kit.tar.gz" && \
  tar -xzvf "set-misc-nginx-module.tar.gz" && \
  tar -xzvf "srcache.tar.gz" && \
  \
  NCHANDIR="$(pwd)/nchan-${NCHAN_VERSION}" && \
  HTTP_REDIS_DIR="$(pwd)/ngx_http_redis-${HTTP_REDIS_VERSION}" && \
  REDIS2_NGINX_DIR="$(pwd)/redis2-nginx-module-${REDIS2_NGINX}" && \
  SEC_HEADERS_DIR="$(pwd)/ngx_security_headers-${NGX_SEC_HEADER}" && \
  MOD_ZIP_DIR="$(pwd)/mod_zip-${MOD_ZIP_VERSION}" && \
  \
  MOD_NGINX_DEVEL_KIT_DIR="$(pwd)/ngx_devel_kit-${NGINX_DEVEL_KIT}" && \
  MOD_SET_MISC_NGINX_MODULE_DIR="$(pwd)/set-misc-nginx-module-${SET_MISC_NGINX_MODULE}" && \
  SRCACHE_NGINX_MODULE_DIR="$(pwd)/srcache-nginx-module-${SRCACHE_NGINX}" && \
  \
  cd /usr/src/nginx-$BUILDER_NGINX_VERSION && \
  CFLAGS="-fcommon" \
  ./configure --with-compat $CONFARGS \
  --with-http_gzip_static_module \
  --add-dynamic-module=$NCHANDIR \
  --add-dynamic-module=$MOD_NGINX_DEVEL_KIT_DIR \
  --add-dynamic-module=$MOD_SET_MISC_NGINX_MODULE_DIR \
  --add-dynamic-module=$SRCACHE_NGINX_MODULE_DIR \
  --add-dynamic-module=$HTTP_REDIS_DIR \
  --add-dynamic-module=$REDIS2_NGINX_DIR \
  --add-dynamic-module=$SEC_HEADERS_DIR \
  --add-dynamic-module=$MOD_ZIP_DIR && \
  \
  cd /usr/src/nginx-$BUILDER_NGINX_VERSION && \
  make modules && \
  \
  mv ./objs/*.so / && \
  ls -al

FROM nginx:${NGINX_VERSION}-alpine${ALPINE_VERSION}

ADD user_fix.sh /usr/local/bin/user_fix.sh

RUN chmod +x /usr/local/bin/user_fix.sh && \
    /usr/local/bin/user_fix.sh && \
    apk update --no-cache && \
    apk upgrade --no-cache && \
    apk upgrade --no-cache musl curl libcurl && \
    apk add --no-cache --update \
      openssl \
      openssl-dev \
      nghttp2 \
      nghttp2-libs \
      libx11 \
      tiff && \
    apk add --no-cache bash shadow openssl libjpeg-turbo

COPY --from=builder /*.so /usr/local/nginx/modules/

WORKDIR /srv/www
EXPOSE 80 443
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
