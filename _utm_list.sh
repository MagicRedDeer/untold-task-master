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

  case "$flag" in
    --retired|-r)
      _utm_json_task_by_status "retired"
      ;;
    --all|-a)
      _utm_json_task_by_status ""
      ;;
    "")
      _utm_json_task_by_status "live"
      ;;
  esac
}
