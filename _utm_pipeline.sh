#!/bin/bash

_UTM_PIPELINE_DIRNAME=.pipeline

_UTM_PYTHON_VERSIONS=(
  "3.7.10"
  "3.9.16"
  "3.10.13"
)

_utm_pipeline_ensure_base_dir() {
  local task=$1

  local pipeline_base_dir="$UTM_TASKDIR/$task/$_UTM_PIPELINE_DIRNAME"

  if ! _utm_ensure_dir "$pipeline_base_dir" ; then
    return 1
  fi
  echo "$pipeline_base_dir"
  return 0
}

_utm_pipeline_ensure_pipeline_dir () {
  local task=$1
  local py_ver=$2
  local os=${3:-$UNTOLD_OS_VERSION}

  if ! _utm_in_array "$py_ver" "${_UTM_PYTHON_VERSIONS[@]}"; then
    _utm_log_error "invalid python version $py_ver !"
    return 1
  fi

  local pipeline_dir

  if ! pipeline_dir="$(_utm_pipeline_ensure_base_dir "$task")/$os/python-$py_ver"
  then
    return 1
  fi

  if ! _utm_ensure_dir "$pipeline_dir" ; then
    return 1
  fi

  echo "$pipeline_dir"
  return 0
}

_utm_pipeline_ensure_config_dir() {
  local task=$1
  local pipeline_dir

  if ! pipeline_config_dir="$(_utm_pipeline_ensure_base_dir "$task")/pipeline-config"
  then
    return 1
  fi

  if ! _utm_ensure_dir "$pipeline_config_dir" ; then
    return 1
  fi

  echo "$pipeline_config_dir"

  return 0
}

_utm_pipeline_write_config () {
  local task=$1
  local task_config_dir

  if ! task_config_dir=$(_utm_pipeline_ensure_config_dir "$task")
  then
    return 1
  fi

  local pipeline_config="$task_config_dir"/untold_pipeline_packages.json

  if [ -f "$pipeline_config" ]; then
    local date_str
    date_str=$(date +"%Y.%m.%d_%H.%M.%S")
    backup="${task_config_dir}/untold_pipeline_packages-${date_str}.json"
    _utm_log_debug "Backing up current config to $backup ..."
    cp "$pipeline_config" "$backup"
  fi

  _utm_lf_generate_config "$task" >| "$pipeline_config"
}

_utm_pipeline_create_repo_links() {
  local task=$1
  local repo=$2
  local repo_location=$3

  local py_ver
  for py_ver in "${_UTM_PYTHON_VERSIONS[@]}"; do
    local pipeline_dir
    pipeline_dir=$(_utm_pipeline_ensure_pipeline_dir "$task" "$py_ver")
    local link="$pipeline_dir"/"$repo"

    _utm_log_debug "Creating link $link -> $repo_location ..."
    if ! ln -s -f -T "$repo_location" "$link"; then
      _utm_log_error "Failed to create link: $link"
    fi
  done
}

_utm_pipeline_remove_repo_links() {
  task=$1
  repo=$2

  local link
  for link in "$UTM_TASKDIR/$task/$_UTM_PIPELINE_DIRNAME"/*/*/"$repo"; do
    if [ ! -h "$link" ]; then
      continue
    fi
    _utm_log_debug "Removing link $link ..."
    if ! rm "$link"; then
      _utm_log_error "Failed to remove link: '$link' !"
    fi
  done
}

