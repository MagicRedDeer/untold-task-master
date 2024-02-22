#!/bin/bash

_UTM_REMOVE_FLAGS=(
  --yes -y
  --keep-builds -b
)

_utm_remove_completions () {
  local words=("$@")
  local num_words=${#words[@]}

  if [[ "$num_words" -eq 1  || ( "$num_words" -le 3 &&  "${words[0]}" =~ ^- )  ]]; then

    local tasks
    readarray -t tasks < <(_utm_list --all)
    _utm_suggest "${words[-1]}" "${tasks[*]}" "${_UTM_REMOVE_FLAGS[*]}"

  fi
}

_utm_remove () {
  local arg=$1

  local confirm=yes
  local remove_builds=yes
  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      "--yes"|"-y")
        confirm=;;
      "--keep-builds"|"-b")
        remove_builds=;;
      *)
        _utm_log_error "Invalid flag '$arg' !"
        _utm_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  local task_name=$1
  shift

  if [ -z "$task_name" ]; then
    _utm_log_error "No task name provided"
    return 1
  fi

  if ! _utm_task_is_valid "$task_name"; then
    _utm_log_error "Task '$task_name' does not exist!"
    return 1
  fi

  if [ -n "$confirm" ]; then
    if ! _utm_confirm "Are you sure you want to delete the task '$task_name'?"; then
      return 1
    fi
  fi

  _utm_log_debug "Removing task '$task_name' ..."

  if [ "$task_name" = "$(_utm_active)" ]; then

    _utm_log_debug "Task '$task_name' is active! removing links ..."
    rm "${UTM_TASKDIR}/${_UTM_ACTIVE_TASK}"
    rm "$HOME/pipeline"
  fi

  local task_dir="$UTM_TASKDIR/$task_name"
  rm -rf "$task_dir"

  [[ -n "$remove_builds" ]] && _utm_build_remove_all "$task_name"
  _utm_lf_remove "$task_name"

  _utm_log_info "Task '$task_name' was removed!"
}
