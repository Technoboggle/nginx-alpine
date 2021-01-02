#!/bin/bash

INITIAL_WD=`pwd

ME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

cd "$DIR"

#####################################################################
# use the following commands to build image and upload to dockerhub #
#####################################################################
docker build -f build-nginx.Dockerfile -t technoboggle/nginx_mods-alpine:1.19.3  .
docker run -it -d -p 8000:80 --rm --name mynginx technoboggle/nginx_mods-alpine:1.19.3-3.12.3
docker tag nginx-mods:1.19.3-alpine technoboggle/nginx_mods-alpine:1.19.3-3.12.3
docker tag nginx-mods:1.19.3-alpine technoboggle/nginx_mods-alpine:latest
docker login
docker push technoboggle/nginx_mods-alpine:1.19.3-3.12.3 technoboggle/nginx_mods-alpine:latest
docker container stop -t 10 mynginx
#####################################################################


#docker run -it -d -p 8000:80 --rm --name mynginx technoboggle/nginx-alpine-mods:latest

cd "$INITIAL_WD"


