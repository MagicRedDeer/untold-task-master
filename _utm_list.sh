#!/bin/bash

_UTM_LIST_FLAGS=(
  "--retired" "-r"
  "--all" "-a"
)

_utm_list_completions() {
  local words=("$@")  
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then
    _utm_suggest "${words[0]}" "" "${_UTM_LIST_FLAGS[*]}"
  fi
}

_utm_list() {
  local flag=$1
  local task_status
  local name

  if [ -n "$flag" ]; then
    if ! _utm_in_array "$flag" "${_UTM_LIST_FLAGS[@]}"; then
      _utm_log_error "Invalid argument: $flag!"
      return 1
    fi
  fi

  for name in "$UTM_TASKDIR"/*
  do
    [ "$name" != "$UTM_TASKDIR/$_UTM_ACTIVE_TASK" ] || continue
    [ -d "$name" ] || continue
    [ -f "$name/$_UTM_JSON_FILENAME" ] || continue


    case "$flag" in
      --retired|-r)
        task_status=$(_utm_task_status "$(basename "$name")")
        [ "$task_status" == "\"retired\"" ] || continue
        ;;
      --all|-a)
        ;;
      *)
        task_status=$(_utm_task_status "$(basename "$name")")
        [ "$task_status" == "\"live\"" ] || continue
        ;;
    esac

    basename "$name"
  done
}
