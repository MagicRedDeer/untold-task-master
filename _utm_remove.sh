#!/bin/bash

_utm_remove_completions () {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    # shellcheck disable=SC2207
    local tasks=($(_utm_list))
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}

_utm_remove () {
  local task_name=$1

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "Task '$task_name' does not exist!"
    return 1
  fi

  _utm_log_debug "Removing task '$task_name' ..."

  if [ "$task_name" = "$(_utm_active)" ]; then

    _utm_log_debug "Task '$task_name' is active! removing links ..."
    rm "${USER_TASKDIR}/${_UTM_ACTIVE_TASK}"
    # rm "$HOME/pipeline"
  fi

  local task_dir="$UTM_TASKDIR/$task_name"
  rm -rf "$task_dir"

  _utm_log_info "Task '$task_name' was removed!"
}
