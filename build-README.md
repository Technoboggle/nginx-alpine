#####################################################################
# use the following commands to build image and upload to dockerhub #
```
#####################################################################
docker build -f build-nginx.Dockerfile -t technoboggle/nginx_mods-alpine:1.19.3-3.12.3  .
docker run -it -d -p 8000:80 --rm --name mynginx technoboggle/nginx_mods-alpine:1.19.3-3.12.3
docker tag nginx-mods:1.19.3-alpine technoboggle/nginx_mods-alpine:1.19.3-3.12.3
docker tag nginx-mods:1.19.3-alpine technoboggle/nginx_mods-alpine:latest
docker login
docker push technoboggle/nginx_mods-alpine:1.19.3-3.12.3
docker push technoboggle/nginx_mods-alpine:latest
docker container stop -t 10 mynginx
#####################################################################
```
