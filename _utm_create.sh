#!/bin/bash

_UTM_FORBIDDEN_TASK_NAMES=(
  "CurrentTask" "currenttask"
  "ActiveTask" "activetask"
  "current" "active"
  "cd" "run" "build" "package" "repo"
  "create" "remove" "activate"
  "retired" "revive" "list"
  "config" "attach"
  "live" "retired"
  "task" "Task"
)

_utm_create() {
  local task_name="${1}"

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided!"
    return 1
  fi

  if _utm_in_array "$task_name" "${_UTM_FORBIDDEN_TASK_NAMES[@]}"; then
    _utm_log_error "You may not name a task '$task_name'"
    return 1
  fi

  # shellcheck disable=SC2207
  existing_tasks=($(_utm_list))
  if  _utm_in_array "$task_name" "${existing_tasks[@]}"; then
    _utm_log_error "A task already exists with the name of '$task_name'!"
    return 1
  fi

  local task_dir
  local json_file_path
  task_dir="$UTM_TASKDIR/$task_name"
  json_file_path="$task_dir/$_UTM_JSON_FILENAME"

  # create task directory
  _utm_log_debug "Creating directory '$task_dir' ..."
  mkdir -p "$task_dir" > /dev/null

  _utm_log_debug "Adding json file at '$json_file_path' ..."
  touch "$json_file_path"

  _utm_log_debug _utm_initialize_utm_json "$task_name" "$json_file_path"
  _utm_initialize_utm_json "$task_name" "$json_file_path"
  _utm_pipeline_config_ensure_base_dir "$task_dir"
}

_utm_initialize_utm_json() {
  local task_name=$1;
  local json_file_path=$2

  if [ -z "$json_file_path" ]; then
    json_file_path="$UTM_TASKDIR/$task_name/$_UTM_JSON_FILENAME"
  fi

  _utm_log_debug "initializing file at '$json_file_path' ..."
  json_content=$(jq \
    --arg task_name "$task_name" \
    -n \
    '{name: $task_name,
      status: "live"}')
  _utm_log_debug "json content:"
  _utm_log_debug "$json_content"
  _utm_log_debug "Writing to $json_file_path ..."
  echo "$json_content" >| "$json_file_path"
}
