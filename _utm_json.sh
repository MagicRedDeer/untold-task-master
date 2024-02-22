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
  local json_content
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
  shift
  local repos=("$@")

  local json_file_path
  json_file_path="$UTM_TASKDIR/$task/$_UTM_JSON_FILENAME"

  local cmd="jq"
  cmd="$cmd --from-file \"$_UTM_JQ_SCRIPTS_DIR/add_repos_to_task.jq\""
  cmd="$cmd \"$json_file_path\""
  cmd="$cmd --args ${repos[*]}"
  # cmd="$cmd >| \"$UTM_TASKDIR/$task/$_UTM_JSON_FILENAME\""
  local json_content

  # _utm_log_debug "$cmd"
  # json_content=$(eval "$cmd")

  _utm_log_debug "Modifying $json_file_path ..."
  json_content=$(jq \
    --from-file "$_UTM_JQ_SCRIPTS_DIR/add_repos_to_task.jq" \
    "$json_file_path" \
    --args "${repos[@]}" \
  )

  _utm_log_debug "new json content: $json_content"
  _utm_log_debug "Writing to $json_file_path ..."
  echo "$json_content" >| "$json_file_path"
}

_utm_json_remove_repos () {
  local task=$1
  shift
  local repos=("$@")

  local json_file_path
  json_file_path="$UTM_TASKDIR/$task/$_UTM_JSON_FILENAME"


  local json_content

  json_content=$(jq \
    --from-file "$_UTM_JQ_SCRIPTS_DIR/remove_repos_from_task.jq" \
    "$json_file_path" \
    --args "${repos[@]}"
  )

  echo "$json_content" >| "$json_file_path"
}

#######################################
# list all tasks filtering by status if provided
#
# Arguments:
#  $1 - status to filter for
#   
#######################################
_utm_json_task_by_status () {
  local status=$1

  local cmd="jq -n -r"

  # Adding json files and data as arguments
  local json_file
  for json_file in "$UTM_TASKDIR"/*/"$_UTM_JSON_FILENAME"; do
    cmd="$cmd --arg \"$json_file\" \"\$(<$json_file)\""
  done

  # Adding status argument
  if [ -n "$status" ]; then
    cmd="$cmd --arg status $status"
  fi

  cmd="$cmd --from-file \"$_UTM_JQ_SCRIPTS_DIR/tasks_by_status.jq\""

  _utm_log_debug "Executing 'jq --from-file $_UTM_JQ_SCRIPTS_DIR/tasks_by_status.jq' for '${status:-all}' tasks ..."
  eval "$cmd"
}

_utm_json_repo_list(){
  local task="$1"
  local json_file_path="$UTM_TASKDIR/$task/$_UTM_JSON_FILENAME"

  _utm_log_debug "Reading list of repos from '$json_file_path' ..."
  jq -r 'try .repos[]' "$json_file_path"
}

_utm_json_lf_repo_list() {
  local json_path=$1
  _utm_log_debug jq -r '.[]' "$json_path"
  jq -r '.[]' "$json_path"
}
