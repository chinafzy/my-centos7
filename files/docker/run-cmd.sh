#!/bin/bash

source /docker/tools.sh

[[ ! -z "$1" ]] \
  && echo2 "[WARNING] Receive sub command: $@" \
  && echo2 "[WARNING] Please override /docker/run-cmd.sh for your own task." \
  && $@
