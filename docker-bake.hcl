# docker-bake.hcl
group "default" {
    targets = ["app"]
}

target "app" {
    context = "."
    dockerfile = "Dockerfile"
    tags = ["technoboggle/nginx_mods-alpine:${NGINX_VERSION}-${ALPINE_VERSION}", "technoboggle/nginx_mods-alpine:${NGINX_VERSION}", "technoboggle/nginx_mods-alpine:latest"]
    args = {
        BUILDER_ALPINE_VERSION="${BUILDER_ALPINE_VERSION}"
        BUILDER_NGINX_VERSION="${BUILDER_NGINX_VERSION}"
        ALPINE_VERSION = "${ALPINE_VERSION}"
        NGINX_VERSION = "${NGINX_VERSION}"
        NCHAN_VERSION = "${NCHAN_VERSION}"
        HTTP_REDIS_VERSION = "${HTTP_REDIS_VERSION}"
        REDIS2_NGINX = "${REDIS2_NGINX}"
        NGX_SEC_HEADER = "${NGX_SEC_HEADER}"
        PCRE_VERSION = "${PCRE_VERSION}"
        MOD_ZIP_VERSION = "${MOD_ZIP_VERSION}"
        SET_MISC_NGINX_MODULE = "${SET_MISC_NGINX_MODULE}"
        SRCACHE_NGINX = "${SRCACHE_NGINX}"
        NGINX_DEVEL_KIT = "${NGINX_DEVEL_KIT}"

        MAINTAINER_NAME = "${MAINTAINER_NAME}"
        AUTHORNAME = "${AUTHORNAME}"
        AUTHORS = "${AUTHORS}"
        VERSION = "${VERSION}"

        SCHEMAVERSION = "${SCHEMAVERSION}"
        NAME = "${NAME}"
        DESCRIPTION = "${DESCRIPTION}"
        URL = "${URL}"
        VCS_URL = "${VCS_URL}"
        VENDOR = "${VENDOR}"
        BUILDVERSION = "${BUILD_VERSION}"
        BUILD_DATE="${BUILD_DATE}"
        DOCKERCMD:"${DOCKERCMD}"
    }
    platforms = ["linux/arm/v6", "linux/arm/v7", "linux/arm64/v8", "linux/arm64", "linux/armhf", "linux/amd64", "linux/386", "linux/s390x", "linux/ppc64le"]
    push = true
    cache = false
    progress = "plain"
}
