#!/bin/bash

_UTM_TD_REPOS=( "untold_td" "u-rig" "playground-td" ) 

_UTM_REPOS=(
  "bala" "botanik" "cask" "cookiecutter-pipeline" "cookiecutter-pip-package"
  "deadline-config" "dwarfs" "hooks-event-handler" "hooks-notify"
  "hooks-settings" "lambda-layers" "lambda-pipe-utils" "media-utils"
  "ocio-config" "pipeline-config" "pipeline-docs" "playground-td"
  "python-config" "python-edl" "sg-web-apps" "shamba" "site-sync"
  "site-sync-hooks" "stem" "sync-tests" "tech" "test-config" "test-project"
  "u-ami" "u-atlas" "u-deploy" "u-log" "u-makeit" "unlint" "untold_cmd"
  "untold-launcher" "untold_shell" "untold_td" "untold-tk-config" "u-pysidelib"
  "u-rig" "u-utils"
)

_UTM_GIT_URL=git@gitlab.lhr.untoldstudios.tv:pipeline
_UTM_GIT_URL_TD=git@gitlab.lhr.untoldstudios.tv:pipeline-td

_UTM_REPO_ADD_FLAGS=()

_utm_repo_add_completions() {
  local words=("$@")  
  # local num_words=${#words[@]}

  _utm_suggest "${words[-1]}" "${_UTM_REPOS[*]}" ""
}

_utm_repo_add() {
  local task=$1
  shift
  local repos=("$@")
  _utm_log_debug "Executing utm repo add '${repos[*]}' on '$task' ..."

  if ! _utm_repo_verify "$task" "${repos[@]}"; then
    return 1
  fi

  if ! _utm_json_add_repos "$task" "${repos[@]}"; then
    _utm_log_error "Cannot add repos '${repos[*]}' to json on '$task'..."
    return 1
  fi

  local lf_add
  local repo

  lf_add=
  for repo in "${repos[@]}"; do
    if ! _utm_repo_add_single "$task" "$repo"; then
      return 1
    fi

    if _utm_lf_verify_single "$repo"; then
      if _utm_lf_package_add_single "$task" "$repo"; then
        lf_add=yes
      fi
    fi

  done

  if [ -n "$lf_add" ]; then
    _utm_log_debug "Writing out config file for task '$task' ..."
    _utm_pipeline_write_config "$task"
  fi
}

_utm_repo_verify() {
  local task=$1
  shift
  local repos=("$@")
  local repo

  _utm_log_debug "Verifying ${#repos[@]} repositories ..."

  for repo in "${repos[@]}"; do
    if ! _utm_in_array "$repo" "${_UTM_REPOS[@]}"; then
      _utm_log_error "Invalid repo name '$repo'!"
      return 1
    fi

    local repo_location
    repo_location=$(_utm_repo_dir_ensure "$task")/$repo
    _utm_log_debug "Checking repo location: $repo_location"
    if [ -e "$repo_location" ]; then
      _utm_log_error "$repo_location already exists!"
      return 1
    fi

  done

  return 0
}

_utm_repo_add_single() {
  local task=$1
  local repo=$2

  local repo_location
  if ! repo_location=$(_utm_repo_dir_ensure "$task")/$repo; then
    return 1
  fi

  if [ -e "$repo_location" ]; then
    _utm_log_error "$repo_location already exists!"
    return 1
  fi

  local git_url
  git_url=$(_utm_repo_git_url "$repo")
  _utm_log_debug "Cloning '$git_url' -> '$repo_location' ..."

  if ! git clone "$git_url" "$repo_location" ; then
    _utm_log_error "Error encountered while cloning '$repo'!"
    return 1
  fi

  _utm_log_debug "$repo cloned successfully!"

  if ! pushd "$repo_location" >/dev/null 2>&1 ; then 
    _utm_log_error "Error $? encountered while pushd"
    return 1
  fi

  _utm_log_debug "Checking out branch '$task' in '$repo' ..."
  if ! git checkout -b "$task" >/dev/null 2>&1 ; then
    _utm_log_error "Error $? encountered while checking out branch"
    return 1
  fi

  popd >/dev/null 2>&1 || return 1

  _utm_repo_create_pipeline_links "$task" "$repo"
}

_utm_repo_dir_ensure() {
  local task=$1
  local repo=$2
  local repo_dir="$UTM_TASKDIR/$task/$_UTM_REPO_DIRNAME"
  if ! _utm_ensure_dir "$repo_dir"; then
    return 1
  fi
  echo "$repo_dir"
  return 0
}

_utm_repo_git_url() {
  local repo=$1
  if _utm_in_array "$repo" "${_UTM_TD_REPOS[@]}"; then
    echo "$_UTM_GIT_URL_TD/$repo"
  else
    echo "$_UTM_GIT_URL/$repo"
  fi
}

_utm_repo_create_pipeline_links () {
  local task=$1
  local repo=$2

  local repo_location
  repo_location=$(_utm_repo_dir_ensure "$task")/$repo

  _utm_pipeline_create_repo_links "$task" "$repo" "$repo_location"
}
