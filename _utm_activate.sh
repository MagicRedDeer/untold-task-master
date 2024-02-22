#!/bin/bash

_UTM_ACTIVE_TASK=.active_task
_UTM_ACTIVATE_FLAGS=()

_utm_activate_completions() {
  local words=("$@")
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then

    local tasks
    readarray -t tasks < <(_utm_list)
    _utm_suggest "${words[0]}" "${tasks[*]}" ""

  fi
}

_utm_activate() {
  local task_name=$1

  if _utm_in_array "$task_name" "${_UTM_ACTIVATE_FLAGS[@]}"; then
    shift
    task_name=$1
  fi

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "'$task_name' is not a valid task"
    return 1
  fi

  if ! _utm_task_is_live "$task_name"; then
    _utm_log_error "'$task_name' is not live!"
    return 1
  fi

  _utm_activate_perform "$task_name"
}

_utm_activate_perform() {
  local task_name=$1
  _utm_log_debug "Activating $task_name ..."

  local task_dir="$UTM_TASKDIR/$task_name"
  _utm_create_pipeline_link "$task_name"
  _utm_create_active_task_link "$task_dir"
  _utm_log_info "Task '$task_name' is now active!"
}

_utm_create_active_task_link () {
  local task_dir=$1
  local active_task_link="$UTM_TASKDIR/$_UTM_ACTIVE_TASK"

  _utm_log_debug "Creating link at $active_task_link -> $task_dir ... "

  if [ -h "$active_task_link" ]; then
    rm "$active_task_link"
  fi

  ln -s -T "$task_dir" "$active_task_link"
}

_utm_create_pipeline_link () {
  local task_dir=$1
  local pipeline_link="$HOME/pipeline"
  local target_dir

  target_dir=$(_utm_pipeline_ensure_base_dir "$task_dir")

  if [ -d "$pipeline_link" ]; then
    _utm_log_debug "Removing existing directory at: $pipeline_link ..."
    rm -rf "$pipeline_link"
  fi

  if [ -h "$pipeline_link" ]; then
    _utm_log_debug "Removing existing link at: $pipeline_link ..."
    rm "$pipeline_link"
  fi

  _utm_log_debug "Creating link at $pipeline_link -> $target_dir" ...
  ln -s -T "$target_dir" "$pipeline_link"
}

_utm_active () {
  local active_task_link="$UTM_TASKDIR/$_UTM_ACTIVE_TASK"

  if [ ! -h "$active_task_link" ]; then
    _utm_log_error "Cannot read active task" 
    return 1
  fi

  active_task_dir=$(readlink -f "$active_task_link")
  basename "$active_task_dir"
}
