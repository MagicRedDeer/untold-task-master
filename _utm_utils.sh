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
         break
     fi
  done
}

_utm_search() {
  local expr=$1
  shift
  local values=("$@") 
  local val
  for val in "${values[@]}"
  do
    [[ "$val" =~ $expr ]] && echo "$val"
  done
}

_utm_obj_is_in_array() {
  local obj=$1
  shift
  local values=("$@") 
  local val
  for val in "${values[@]}"; do
    [[ "$obj" = "$val" ]] && return 0
  done
  return 1
}
