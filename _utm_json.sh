#!/bin/bash

_UTM_JSON_FILENAME=.utm.json
_UTM_JQ_SCRIPTS_DIR="$_UTM_DIRECTORY/jq_scripts"

_utm_json_initialize() {
  local task_name=$1;
  local json_file_path=$2

  if [ -z "$json_file_path" ]; then
    json_file_path="$UTM_TASKDIR/$task_name/$_UTM_JSON_FILENAME"
  fi

  _utm_log_debug "initializing file at '$json_file_path' ..."
  json_content=$(jq \
    --arg task_name "$task_name" \
    -n \
    '{
      name: $task_name,
      status: "live",
      repos: []
    }')
  _utm_log_debug "json content: $json_content"
  _utm_log_debug "Writing to $json_file_path ..."
  echo "$json_content" >| "$json_file_path"
}

_utm_json_add_repos () {
  local task="$1"
  local repos=("$@")
}

_utm_json_task_by_status () {
  local status=$1

  local cmd="jq -n -r "

  # Adding json files and data as arguments
  local json_file
  for json_file in "$UTM_TASKDIR"/*/"$_UTM_JSON_FILENAME"; do
    cmd="$cmd --arg \"$json_file\" \"\$(<$json_file)\""
  done

  # Adding status argument
  if [ -n "$status" ]; then
    cmd="$cmd --arg status $status"
  fi

  cmd="$cmd --from-file \"$_UTM_JQ_SCRIPTS_DIR/filter_tasks.jq\""

  _utm_log_debug "$cmd"
  eval "$cmd"
}
