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

_UTM_CREATE_FLAGS=(
  "--activate" "-a"
)


_utm_create_completions () {
  local words=("$@")
  local num_words=${#words[@]}

  if [[ "$num_words" -eq 1  || ( "$num_words" -eq 2 &&  "${words[0]}" =~ ^- )  ]]; then

    _utm_suggest "${words[-1]}" "${_UTM_CREATE_FLAGS[*]}" "${_UTM_CREATE_FLAGS[*]}"

  fi
}


_utm_create() {
  local arg=$1

  local activate=
  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --activate|-a)
        activate=yes;;
      *)
        _utm_log_error "Invalid flag '$arg' !"
        _utm_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  local task_name="${1}"

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided!"
    return 1
  fi

  if _utm_in_array "$task_name" "${_UTM_FORBIDDEN_TASK_NAMES[@]}"; then
    _utm_log_error "Sorry! You may not name a task '$task_name'"
    return 1
  fi

  local sanitized
  sanitized=$(_utm_sanitize "$task_name")
  if [ "$task_name" != "$sanitized" ]; then
    _utm_log_error "'$task_name' is not a good task name ... try '${sanitized:-name}'"
    return 1
  fi


  local existing_tasks
  readarray -t existing_tasks < <(_utm_list)
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
  _utm_json_initialize "$task_name" "$json_file_path"
  _utm_pipeline_ensure_base_dir "$task_dir" > /dev/null

  _utm_pyright_task_json_deploy "$task_name"

  _utm_log_info "A task named '$task_name' was created"
  [[ -n $activate ]] && _utm_activate_perform "$task_name"
}
