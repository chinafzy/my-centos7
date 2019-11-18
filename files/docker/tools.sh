#!/bin/bash

function echo2(){
  echo $(date '+%Y-%m-%d %H-%M-%S-%3N'): $@
}

function printf2(){
  printf $(date '+%Y-%m-%d %H-%M-%S-%3N'): $@
}
