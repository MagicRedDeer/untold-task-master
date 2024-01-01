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
  local repo
  _utm_log_debug "Executing utm repo add '${repos[*]}' on '$task' ..."
  for repo in "${repos[@]}"; do
    _utm_repo_add_single "$task" "$repo"
  done
}

_utm_repo_add_single() {
  local task=$1
  local repo=$2
  _utm_log_debug "Adding repo '$repo' to '$task' ..."
}

