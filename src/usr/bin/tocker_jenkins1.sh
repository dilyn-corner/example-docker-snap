#!/bin/sh

docker run --name tocker-jenkins1 \
    -v jenkins-vol:/var/jenkins_home \
    -p 8001:8080 -p 50000:50000 \
    jenkins/jenkins
