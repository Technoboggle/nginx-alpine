
[![Known Vulnerabilities](https://snyk.io/test/github/Technoboggle/nginx-alpine/badge.svg)](https://snyk.io/test/github/Technoboggle/nginx-alpine)



# The following commands to build image and upload to dockerhub
```

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh


# for more build detail add the following argument:  --progress=plain
docker build -f Dockerfile -t technoboggle/nginx_mods-alpine:1.21.5-3.15.3 .
docker run -it -d -p 8000:80 --rm --name mynginx technoboggle/nginx_mods-alpine:1.21.5-3.15.3
docker tag technoboggle/nginx_mods-alpine:1.21.5-3.15.3 technoboggle/nginx_mods-alpine:latest
docker login
docker push technoboggle/nginx_mods-alpine:1.21.5-3.15.3
docker push technoboggle/nginx_mods-alpine:latest
docker container stop -t 10 mynginx

