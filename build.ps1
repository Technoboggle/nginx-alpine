docker build -f Dockerfile.build -t nginx-alpine-mods:latest .
docker run -it -d -p 8000:80 --rm --name mynginx nginx-alpine-mods
docker tag nginx-alpine-mods technoboggle/nginx-alpine-mods:latest
docker push technoboggle/nginx-alpine-mods:latest
docker container stop -t 10 mynginx
