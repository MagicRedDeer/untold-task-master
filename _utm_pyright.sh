#!/bin/bash


_UTM_PYRIGHT_JSON_TASK="$UTM_DIR/pyright/pyright-task.json"


_utm_pyright_task_json_deploy() {
  task=$1

  local task_location
  task_location="$UTM_TASK_DIR/$task/$_UTM_REPO_DIRNAME/$repo"

  if [ ! -d "$task_location" ]; then
    _utm_log_error "Task dir '$task_location' does not exist"
    return 1
  fi

  local pyright_config_path="$task_location/pyrightconfig.json"
  _utm_log_debug "Creating task config at $pyright_config_path"
  cp "$_UTM_PYRIGHT_JSON_TASK" "$pyright_config_path" > /dev/null
}


_utm_pyright_repo_json_deploy() {
  task=$1
  repo=$2

  local repo_location
  repo_location="$UTM_TASK_DIR/$task/$_UTM_REPO_DIRNAME/$repo"

  if [ ! -d "$repo_location" ]; then
    _utm_log_error "Task dir '$repo_location' does not exist"
    return 1
  fi

  local pyright_config_path="$repo_location/pyrightconfig.json"

  _utm_log_debug "Creating repo config at $pyright_config_path"
  cp "$_UTM_PYRIGHT_JSON_TASK" "$pyright_config_path" > /dev/null

  local exclude_file
  exclude_file="$repo_location"/.git/info/exclude

  _utm_log_debug "Updating $exclude_file"
  echo >> "$exclude_file"
  echo "pyrightconfig.json" >> "$exclude_file"
}


