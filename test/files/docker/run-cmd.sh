#!/bin/bash

source /docker/tools.sh

[[ ! -z "$1" ]] \
  && echo2 "[Testing] Receive sub command:$@" \
  && $@
