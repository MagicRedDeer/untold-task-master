#!/bin/bash


_utm_dir_completions() {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    local tasks
    readarray -t tasks < <(_utm_list)
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}


_utm_dir() {
  _utm_dir_cmds_perform "echo" "$@"
}


_utm_cd() {
  _utm_dir_cmds_perform "cd" "$@"
}

_utm_pushd() {
  _utm_dir_cmds_perform "pushd" "$@"
}

_utm_dir_cmds_perform () {
  local cmd="${1}"
  local task_name="${2}"

  [ -z "$task_name" ] && task_name=$(_utm_active)

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "Task '$task_name' does not exist!"
    return 1
  fi

  "$cmd" "$UTM_TASKDIR/$task_name" || return 1
}
