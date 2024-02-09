#!/bin/bash

_utm_revive_completions () {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    local tasks
    readarray -t tasks < <(_utm_list --retired)
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}

_utm_revive () {
  local task_name=$1

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_retired "$task_name"; then
    _utm_log_error "'$task_name' is not a retired task"
  fi

  local json_filepath
  json_filepath="$(_utm_task_json_filepath "$task_name")"

  _utm_log_debug "Modifying $json_filepath ..."

  local json_content
  json_content=$(jq \
    '. += {"status": "live"}' \
    "$json_filepath") # >| "$json_filepath"
  _utm_log_debug "New json content:"
  _utm_log_debug "$json_content"

  _utm_log_debug "Writing to $json_filepath ..."
  echo "$json_content" >| "$json_filepath"

}
