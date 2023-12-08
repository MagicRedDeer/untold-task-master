#!/bin/bash

_utm_task_is_valid() {
  local tasks
  tasks=$(_utm_list)
  echo "$tasks" | tr " " '\n' | grep -F -q -x "$1"
}

_utm_location_in_array() {
  local value=$1
  shift
  local arr=("$@")
  for i in "${!arr[@]}"; do
     if [[ "${arr[$i]}" = "${value}" ]]; then
         echo "${i}";
     fi
  done
}
