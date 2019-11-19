#!/bin/bash

pushd $(dirname $0)

V=$(cat $(dirname $0)/versions.md | grep "## " | head -n 1 | awk '{print $2}')

# origin	git@github.com:chinafzy/my-centos7.git (push)
# docker.pkg.github.com/chinafzy/my-centos/my-centos7:$V 
T=$(git remote -v | grep 'origin' | grep '(push)' | grep 'git@github.com' \
  | awk -v V="$V" -F '[@ :\t/\.]' '{print "docker.pkg.github.com/" $5 "/" $6 "/" $6 ":" V }')


docker build -t $T ./

popd
