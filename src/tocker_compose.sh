#!/bin/sh

#export PATH=$SNAP/docker-bin/usr/bin:$SNAP/docker-bin/bin:$PATH
export PATH=$SNAP/docker-bin/bin:$PATH
export PYTHONPATH=$SNAP/docker-bin/lib/python3.6/site-packages:$PYTHONPATH
docker-compose -f $SNAP/usr/share/composers/hello-nginx.yml up
