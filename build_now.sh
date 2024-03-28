#!/usr/bin/env sh

owd="$(pwd)"
cd "$(dirname "$0")" || exit

BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
VCS_REF="$(git rev-parse --verify HEAD)"

export BUILD_DATE
export VCS_REF

sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE="'"${BUILD_DATE}"'"/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF="'"${VCS_REF}"'"/g' env.hcl

if [ -f env.hcl ]; then
    while IFS= read -r line; do
        export "$line"
    done <env.hcl
fi

DOCKERCMD='docker run -it -d --rm -p 8000:80 --name mynginx technoboggle/nginx_mods-alpine:'"${NGINX_VERSION//\"/}-${ALPINE_VERSION//\"/}"

sed -i.bu -E 's#DOCKERCMD=".*"#DOCKERCMD="'"${DOCKERCMD//\"/}"'"#g' env.hcl

export DOCKERCMD

if [ -f .perms ]; then
    export $(cat .perms | xargs)
fi

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c ./*

find "$(pwd)" -type d -exec chmod ugo+x {} \;
find "$(pwd)" -type f -exec chmod ugo=wr {} \;
find "$(pwd)" -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;
chmod 0666 .gitignore
chmod 0666 .dockerignore

chmod 0777 hooks/build

docker login -u="${DOCKER_USER}" -p="${DOCKER_PAT}"

current_builder=$(docker buildx ls | grep -i '\s\*' | head -n1 | awk '{print $1;}')
echo "Current builder is: ${current_builder}, switching to technoboggle_builder."

# The following is be for a local builder
docker buildx create --name technoboggle_builder --use --bootstrap
docker buildx bake -f env.hcl -f docker-bake.hcl --builder technoboggle_builder --no-cache --push

echo
echo
echo
# The following would be for a remote builder
#docker buildx create --driver cloud technoboggle/test
#docker buildx bake -f docker-bake.hcl -f env.hcl --builder cloud-technoboggle-builder --no-cache --push
sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE=""/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF=""/g' env.hcl
sed -i.bu -E 's/DOCKERCMD=".*"/DOCKERCMD=""/g' env.hcl

rm -f env.hcl.bu


echo "Running the container, using the following command:"
echo "  ${DOCKERCMD}"
echo
docker run -it -d --rm -p 8000:80 --name mynginx technoboggle/nginx_mods-alpine:"${NGINX_VERSION//\"/}-${ALPINE_VERSION//\"/}"
docker container stop -t 10 mynginx

echo "Switching back to builder: ${current_builder}"
docker buildx use "${current_builder}"
docker buildx rm technoboggle_builder

cd "$owd" || exit
