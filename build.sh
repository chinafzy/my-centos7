#!/bin/bash

V=$(cat $(dirname $0)/versions.md | grep "##" | head -n 1 | awk '{print $2}')

docker build -t my-centos7:$V $(dirname $0)
docker tag my-centos7:$V docker.pkg.github.com/chinafzy/my-centos/my-centos7:$V