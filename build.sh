#!/bin/bash

V=$(cat $(dirname $0)/versions.md | grep "## " | head -n 1 | awk '{print $2}')

docker build -t my-centos7 $(dirname $0)
docker build -t my-centos7:$V $(dirname $0)
