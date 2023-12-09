#!/bin/bash

UTM_ACTIVATE_FLAGS=(
  "--expr"
)

_utm_activate_completions() {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    if [[ "${words[0]}" =~ ^- ]]; then
      compgen -W "${UTM_ACTIVATE_FLAGS[*]}" -- "${words[0]}" 
    else
      compgen -W "$(_utm_list)" "${words[0]}" 
    fi

  elif [ "$num_words" -eq 2 ]; then
    #
     # shellcheck disable=SC2046
    [ "${words[0]}" = "--expr" ] && _utm_search "${words[1]}" $(_utm_list) 

  fi
}

_utm_activate() {
  local task_name=$1

  if _utm_in_array "$task_name" "${UTM_ACTIVATE_FLAGS[@]}"; then
    shift
    task_name=$1
  fi

  if [ -z "$task_name" ]; then
    echo No task name provided
    return 1
  elif _utm_task_is_valid "$task_name"; then
    # "$USER_TASKDIR/$task_name/task_manage" activate
    echo activating "$task_name" ...
  else
    echo "$task_name is not a valid task"
    return 1
  fi
}
