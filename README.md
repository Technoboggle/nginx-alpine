
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
docker build -f Dockerfile -t technoboggle/nginx_mods-alpine:1.22.0-3.15.5 --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF="`git rev-parse --verify HEAD`" --build-arg BUILD_VERSION=0.05 --no-cache --progress=plain .
in the above pay special attenttion to the values to be updated which are:
  "`git rev-parse --verify HEAD`"  = git commit SHA key (this can be found with: git rev-parse --verify HEAD )
  0.05                             = current version of this image


docker run -it -d -p 8000:80 --rm --name mynginx technoboggle/nginx_mods-alpine:1.22.0-3.15.5
docker tag technoboggle/nginx_mods-alpine:1.22.0-3.15.5 technoboggle/nginx_mods-alpine:latest
docker login
docker push technoboggle/nginx_mods-alpine:1.22.0-3.15.5
docker push technoboggle/nginx_mods-alpine:latest
docker container stop -t 10 mynginx

