#!/bin/bash

source /docker/tools.sh

log_path="/var/log/docker"
log_file="$log_path/entrypoint.log"

function setup_logs(){
  [[ ! -d $log_path ]] \
    && mkdir -p $log_path

  [[ "$LOG_STDOUT" == "1" ]] && [[ ! -e $log_path/entrypoint.log ]] \
    && echo2 "Bind logs($log_path/entrypoint.log) to /dev/stdout" \
    && ln -s /dev/stdout $log_path/entrypoint.log 
}

function run_d(){
  local folder="/docker/entrypoint.d"

  for file in $(2>/dev/null ls $folder/*.{sh,py}); do

    if [[ "$file" == *"-once"* ]]; then
      local run_log=$file".log"

      [[ -f $run_log ]] && continue
        
      echo2 "[ENTRYPOINT] Start $file " \
        && $file | tee $run_log \
        && echo2 "[ENTRYPOINT] End $file " 
    else
      echo2 "[ENTRYPOINT] Start $file" \
        && $file \
        && echo2 "[ENTRYPOINT] End $file"
    fi
    
    local last_code=$?
    [[ "$last_code" != "0" ]] \
      && echo2 "Command fails. Exiting..." \
      && exit $last_code ;
  done
}

function main() {
  echo2 "[ENTRYPOINT] starts with:$@"

  run_d

  [[ ! -z "$1" ]] \
    && echo2 "[ENTRYPOINT] run sub command:$@" \
    && /docker/run-cmd.sh $@

  echo2 "[ENTRYPOINT] ends"

  [[ "$KEEP_RUNNING" == "1" ]] \
    && echo2 "KEEP_RUNNING " && tail -f /dev/null \
    || echo2 "Please set env KEEP_RUNNING=1 if you wanna keep running."
}


[[ -e /docker/logo.txt ]] && cat /docker/logo.txt 

setup_logs

main $@ >> $log_file
