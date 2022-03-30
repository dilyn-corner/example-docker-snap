#!/bin/sh

SECRETSPATH=$SNAP/usr/share/composers/secrets

docker config ls --filter name=site.key ||\
    docker secret create site.key "$SECRETSPATH/site.key"
docker config ls --filter name=site.crt ||\
    docker secret create site.crt "$SECRETSPATH/site.crt"

docker service create \
    --name nginx \
    --secret site.key \
    --secret site.crt \
    --config source="$SECRETSPATH/site.conf",target=/etc/nginx/conf.d/site.conf,mode=0440 \
    --publish published=3000,target=443 \
    nginx:latest \
    sh -c "exec nginx -g 'daemon off;'"
