#!/bin/sh

export PATH="$SNAP/docker-bin/bin:$PATH"

docker run --name tocker-jenkins2 \
    -v jenkins-vol:/var/jenkins_home \
    -p 9090:9090 -p 60000:50000 \
    jenkins/jenkins
