#!/bin/bash


_UTM_LF=${_UTM_LF:-"$HOME/Workspace/Repos/LionFish/venv/bin/lf"}
_UTM_LF_SESSION_DIR=${_UTM_LF_SESSION_DIR:-"$HOME/.lionfish"}
_UTM_LF_VALID_PACKAGES=(
  "stem" "u-utils" "u-deploy" "site-sync" "dwarfs" "media-utils"
  "shamba" "botanik" "u-log" "bala" "u-atlas" "ocio-config"
  "u-makeit" "unlint" "untold-launcher" "untold_td"
  "pipeline-config"
)


_utm_lf_ensure() {
  local task=$1
  local lf_session_file="$_UTM_LF_SESSION_DIR/$task.json"
  if [ ! -f "$lf_session_file" ]; then
    _utm_log_debug "Creating lf session $task ..."
    $_UTM_LF new "$task" > /dev/null 2>&1
  fi
  return 0
}

_utm_lf_remove() {
  local task=$1
  local lf_env_file="$_UTM_LF_SESSION_DIR/$task.json" 
  if [ -f "$lf_env_file" ]; then
    rm lf_env_file > /dev/null
    return $?
  fi
  return 0
}


_utm_lf_verify_repos() {
  local repos=("$@")
  local repo
  for repo in "${repos[@]}"; do
    if ! _utm_lf_verify_single "$repo"; then
      return 1
    fi
  done
  return 0
}


_utm_lf_verify_single() {
  local repo=$1
  _utm_in_array "$repo" "${_UTM_LF_VALID_PACKAGES[@]}"
  return $?
}


_utm_filter_repos() {
  local repos=("$@")
  for repo in "${repos[@]}"; do
    if _utm_lf_verify_single "$repo"; then
       echo "$repo"
    fi
  done
}


_utm_lf_package_add_single() {
  local task=$1
  local repo=$2

  if [ -z "$repo" ]; then
    _utm_log_error "Please provide a package to add!"
    return 1
  fi

  if ! _utm_lf_verify_single "$repo"; then
    _utm_log_error "Invalid package for Lionfish '$repo'!"
    return 1
  fi
    
  _utm_lf_ensure "$task"

  _utm_log_debug "Adding package '$repo' to '$task' ..."
  _utm_log_debug "$_UTM_LF" package -env "$task" -add "$repo"

  local lf_msg
  lf_msg=$("$_UTM_LF" package -env "$task" -add "$repo" 2>&1)

  if [ -n "$lf_msg" ]; then
    _utm_log_error "$lf_msg"
    return 1
  fi
}


_utm_lf_package_add () {
  local task=$1
  shift
  local repos=("$@")

  readarray -t repos < <(_utm_filter_repos "${repos[@]}")

  _utm_lf_ensure "$task"
  local repo
  for repo in "${repos[@]}"; do
    if ! _utm_lf_package_add_single "$task" "$repo"; then
      return 1
    fi
  done
  return 0
}


_utm_lf_package_remove_single() {
  local task=$1
  local repo=$2

  if [ -z "$repo" ]; then
    _utm_log_error "Please provide a package to add!"
    return 1
  fi

  if ! _utm_lf_verify_single "$repo"; then
    _utm_log_error "Invalid package for Lionfish '$repo'!"
    return 1
  fi
    
  _utm_lf_ensure "$task"

  _utm_log_debug "Removing package '$repo' to '$task' ..."
  _utm_log_debug "$_UTM_LF" package -env "$task" -rm "$repo"

  local lf_msg
  lf_msg=$("$_UTM_LF" package -env "$task" -rm "$repo" 2>&1)

  if [ -n "$lf_msg" ]; then
    _utm_log_error "$lf_msg"
    return 1
  fi
}


_utm_lf_package_remove () {
  local task=$1
  shift
  local repos=("$@")

  readarray -t repos < <(_utm_filter_repos "${repos[@]}")

  _utm_lf_ensure "$task"
  local repo
  for repo in "${repos[@]}"; do
    if ! _utm_lf_package_remove_single "$task" "$repo"; then
      return 1
    fi
  done
  return 0
}


_utm_lf_generate_config() {
  local task=$1
  _utm_lf_ensure "$task"
  $_UTM_LF package -env "$task" -print
  return 0
}


_utm_lf_build() {
  local task=$1
  local build_dir=$2

  _utm_log_debug "$_UTM_LF" build -env "$task" --prefix "$build_dir"
  "$_UTM_LF" build -env "$task" --prefix "$build_dir"
}


_utm_lf_repo_list() {
  local task=$1
  _utm_json_lf_repo_list "$_UTM_LF_SESSION_DIR/$task.json"
}


_utm_lf_package_list() {
  local task=$1
  _utm_log_debug "$_UTM_LF" package -env "$task"
  "$_UTM_LF" package -env "$task"
}


_utm_lf_run() {
  local task=$1
  local build_name=${2:-live}
  local python_version=${3:-"3.7.10"}
  shift 2
  local command=$1

  local task_build_dir
  task_build_dir=$(_utm_build_task_build_dir_ensure "$task")

  local build_dir
  build_dir="$task_build_dir/$build_name"

  if [ ! -d "$build_dir" ]; then
    _utm_log_error "Directory '$build_dir' does not exist"
    return 1
  fi

  _utm_log_debug "$_UTM_LF" run -env "$build_dir" -c "$command" -- "$@"
  "$_UTM_LF" run -env "$build_dir" -p "$python_version" -c "$command" -- "$@"
}
