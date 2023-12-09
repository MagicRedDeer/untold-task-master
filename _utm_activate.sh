#!/bin/bash

_utm_activate_completions() {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    # shellcheck disable=SC2207
    local tasks=($(_utm_list))
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}

_utm_activate() {
  local task_name=$1

  if _utm_in_array "$task_name" "${UTM_ACTIVATE_FLAGS[@]}"; then
    shift
    task_name=$1
  fi

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  elif _utm_task_is_valid "$task_name"; then
    # "$USER_TASKDIR/$task_name/task_manage" activate
    _utm_log_debug "activating '$task_name' ..."
  else
    _utm_log_error "'$task_name' is not a valid task"
    return 1
  fi
}
