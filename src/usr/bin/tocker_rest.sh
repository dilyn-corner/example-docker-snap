#!/bin/sh

list() {
    curl --unix-socket /run/docker.sock -X GET http://v1.41/containers/json
}

nginxImage() {
    curl --unix-socket /run/docker.sock -X POST \
        http://v1.41/images/create?fromImage=nginx:latest
}

nginxServer() {
    curl --unix-socket /run/docker.sock -X POST    \
        -H "Content-Type: application/json"        \
        -d "@$SNAP/usr/share/composers/nginx.json" \
        http://v1.41/containers/create?name=nginxServer
}

nginxStart() {
    curl --unix-socket /run/docker.sock -X POST \
        http://v1.41/containers/nginxServer/start
}

direct() {
    curl "$@"
}

"$@"
