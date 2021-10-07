#!/bin/sh

export PATH=$SNAP/docker-bin/bin:$PATH
docker "$@"
