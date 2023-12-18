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
  local task_name
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

    task_name=$(basename "$name")
    task_status=$(_utm_task_status "$task_name")

    case "$flag" in
      --retired|-r)
        [ "$task_status" == "\"retired\"" ] || continue
        ;;
      --all|-a)
        ;;
      *)
        [ "$task_status" == "\"live\"" ] || continue
        ;;
    esac

    echo "$task_name"
  done
}
