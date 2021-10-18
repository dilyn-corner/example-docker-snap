#!/bin/sh

export PATH="$SNAP/docker-bin/bin:$PATH"

docker run --name tocker-jenkins1 \
    -v jenkins-vol:/var/jenkins_home \
    -p 8080:8080 -p 50000:50000 \
    jenkins/jenkins
