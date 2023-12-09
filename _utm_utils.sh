#!/bin/bash

# Check if the provided task is valid
_utm_task_is_valid() {
  local task="$1"
  local tasks
  tasks=$(_utm_list)
  echo "$tasks" | tr " " '\n' | grep -F -q -x "$task"
}

# return the location of an object in an array
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

# Search for a matching statement in an array
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

# Check if object is in an array
_utm_in_array() {
  local obj=$1
  shift
  local values=("$@") 
  local val
  for val in "${values[@]}"; do
    [[ "$obj" = "$val" ]] && return 0
  done
  return 1
}
