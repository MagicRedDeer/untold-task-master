#!/bin/bash

# Check if the provided task is valid
_utm_task_is_valid() {
  local task="$1"
  local tasks
  _utm_log_debug "verifying task validity for '$task' ..."
  tasks=$(_utm_list --all)
  echo "$tasks" | tr " " '\n' | grep -F -q -x "$task"
}

_utm_task_json_filepath() {
  local task_name=$1
  echo "$UTM_TASKDIR/$task_name/$_UTM_JSON_FILENAME"
}

_utm_task_status () {
  local task_name=$1
  local json_path
  json_path=$(_utm_task_json_filepath "$task_name")
  [[ -f "$json_path" ]] || return 1
  jq -r '.status' "$json_path"
}

_utm_task_is_retired () {
  task_status=$(_utm_task_status "$1")
  [ "$task_status" == "retired" ] && return 0
  return 1
}

_utm_task_is_live () {
  task_status=$(_utm_task_status "$1")
  [ "$task_status" == "live" ] && return 0
  return 1
}

_utm_task_check_live() {
  local task=$1
  if [ -z "$task" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi
  if ! _utm_task_is_valid "$task"; then
    _utm_log_error "Task '$task' is not valid!"
    return 1
  fi
  if ! _utm_task_is_live "$task"; then
    _utm_log_error "Task '$task' is not live!"
    return 1
  fi
  return 0
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
  [ -z "$_UTM_VERBOSE" ] || >&2 echo "DEBUG:" "$@" 
}

_utm_log_error() {
  >&2 echo "ERROR:" "$@"
}

_utm_log_info() {
  >&2 echo "$@"
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

_utm_ensure_dir() {
  local dirpath=$1

  if [ -e "$dirpath" ]; then
    if [ ! -d "$dirpath" ]; then
      _utm_log_debug "Removing file found at $dirpath ..." 
      if ! rm "$dirpath" > /dev/null; then
        _utm_log_error "Cannot remove file found at $dirpath"
        return 1
      fi
    fi
  fi


  if ! mkdir -p "$dirpath" > /dev/null; then
    _utm_log_error "Cannot create directory at $dirpath"
    return 1
  fi

  return 0
}

_utm_confirm() {
  local question=${1:="Are you sure?"}
  question="$question (y/n) "
  read -p "$question" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
     return 0 
  fi
  return 1
}

_utm_sanitize() {
  local string=$1

  local clean=
  # next, replace spaces with underscores
  clean=${clean// /_}
  # clean all numbers from beginning of string
  # shellcheck disable=2001
  clean=$(echo "${string}" | sed 's/^[0-9_-]*//g')
  # now, clean out anything that's not alphanumeric or an underscore
  clean=${clean//[^a-zA-Z0-9_-]/}
  echo "$clean"
}
