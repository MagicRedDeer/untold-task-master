#!/bin/bash

# Check if the provided task is valid
_utm_task_is_valid() {
  local task="$1"
  local tasks
  tasks=$(_utm_list)
  echo "$tasks" | tr " " '\n' | grep -F -q -x "$task"
}

# return the location of an object in an array
_utm_find() {
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

_utm_log_debug() {
  [ -z "$_UTM_VERBOSE" ] || echo "DEBUG:" "$@" 
}

_utm_log_error() {
  >&2 echo "ERROR:" "$@"
}

_utm_log_info() {
  echo "$@"
}

_utm_echos() {
  local stream=${1:-info}
  shift
  [[ "$stream" == "error" ]] && >&2 echo "$@" && return
  [[ "$stream" == "info" ]] && echo "$@" && return
  return 1
}

_utm_suggest() {
  local word="${1}"
  local terms
  local flags

  IPS=" " read -r -a terms <<< "${2}"
  IPS=" " read -r -a flags <<< "${3}"
  
  if [[ "$word" =~ ^- ]]; then
    compgen -W "${flags[*]}" -- "${word}"
  elif [[ "$word" =~ ^~ ]]; then
    _utm_search "${word:1}" "${terms[@]}"
  else
    compgen -W "${terms[*]}" -- "${word}"
  fi
}

_utm_join () {
  local sep="${1}"
  shift
  local str_array
  read -r -a str_array <<< "$@"

  echo "${str_array[*]}" | tr " " "$sep"
}
