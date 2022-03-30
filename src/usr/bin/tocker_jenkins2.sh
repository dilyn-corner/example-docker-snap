#!/bin/sh

docker run --name tocker-jenkins2 \
    -v jenkins-vol:/var/jenkins_home \
    -p 8002:8080 -p 60000:50000 \
    jenkins/jenkins
