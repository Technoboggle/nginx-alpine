#!/usr/bin/env sh

owd="$(pwd)"
cd "$(dirname "$0")" || exit

nginx_ver="1.21.6"
nginx_final_ver="1.25.1"
alpine_ver="3.17.1"

current_builder=$(docker buildx ls | grep -i '\*' | head -n1 | awk '{print $1;}')

docker buildx create --name tb_builder --use --bootstrap

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c ./*
chmod 0666 ./*
chmod 0777 ./*.sh

#docker buildx build --platform linux/arm64,linux/amd64,linux/386 -t technoboggle/"nginx_mods-alpine:${nginx_final_ver}-${alpine_ver}" --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg NGINX_VERSION="$nginx_ver" --build-arg NGINX_FINAL_VERSION="${nginx_final_ver}" --build-arg NCHAN_VERSION="1.3.1" --build-arg HTTP_REDIS_VERSION="0.3.9" --build-arg NGX_SEC_HEADER="0.0.11" --build-arg VCS_REF="$(git rev-parse --verify HEAD)" --build-arg BUILD_VERSION=0.06 --no-cache .

docker login -u="technoboggle" -p="dckr_pat_FhwkY2NiSssfRBW2sJP6zfkXsjo"

docker buildx build -f Dockerfile --platform linux/arm64,linux/amd64,linux/386 \
    -t technoboggle/"nginx_mods-alpine:${nginx_final_ver}-${alpine_ver}" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg NGINX_VERSION="${nginx_ver}" \
    --build-arg NCHAN_VERSION="1.3.6" \
    --build-arg HTTP_REDIS_VERSION="0.3.9" \
    --build-arg REDIS2_NGINX="0.15" \
    --build-arg NGX_SEC_HEADER="0.0.11" \
    --build-arg PCRE_VERSION="8.45" \
    --build-arg MOD_ZIP_VERSION="1.2.0" \
    --build-arg VCS_REF="$(git rev-parse --verify HEAD)" \
    --build-arg BUILD_VERSION=0.06 \
    --no-cache \
    --push .

#--progress=plain

docker run -it -d --rm -p 8000:80 --name mynginx technoboggle/nginx_mods-alpine:"${nginx_final_ver}-${alpine_ver}"
##docker tag technoboggle/nginx_mods-alpine:"${nginx_final_ver}-${alpine_ver}" technoboggle/nginx_mods-alpine:latest
#docker login -u="technoboggle" -p="dckr_pat_FhwkY2NiSssfRBW2sJP6zfkXsjo"
#docker push technoboggle/"${prefix}nginx_mods-alpine:${nginx_final_ver}-${alpine_ver}"
##docker push technoboggle/nginx_mods-alpine:latest
docker container stop -t 10 mynginx

docker buildx use "${current_builder}"
docker buildx rm tb_builder

cd "$owd" || exit
