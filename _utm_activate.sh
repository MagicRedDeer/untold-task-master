#!/bin/bash

_utm_activate_completions() {
  local words=("$@")
  local num_words=${#words[@]}
  if [ "$num_words" -eq 1 ]
  then
    # shellcheck disable=SC2046
    _utm_search "${words[0]}" $(_utm_list) 
  fi
}

_utm_activate() {
  local task_name=$1
  if _utm_task_is_valid "$task_name"; then
    # "$USER_TASKDIR/$task_name/task_manage" activate
    echo activating "$task_name" ...
  else
    echo "$task_name is not a valid task"
    return 1
  fi
}
