#!/bin/bash

_utm_dir_completions() {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    # shellcheck disable=SC2207
    local tasks=($(_utm_list))
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}

_utm_dir() {
  local task_name="${1}"

  [ -z "$task_name" ] && task_name=$(_utm_active)


  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "Task '$task_name' does not exist!"
    return 1
  fi

  echo "$UTM_TASKDIR/$task_name"
}


_utm_cd() {
  local task_name="${1}"

  [ -z "$task_name" ] && task_name=$(_utm_active)

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "Task '$task_name' does not exist!"
    return 1
  fi

  cd "$UTM_TASKDIR/$task_name" || return 1
}
