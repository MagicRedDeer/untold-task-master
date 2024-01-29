#!/bin/bash

_UTM_REPO_REMOVE_FLAGS=(
  --yes -y
)

_utm_repo_remove_completions() {
  local task=$1
  shift
  local words=("$@")

  # shellcheck disable=SC2207
  local repos=($(_utm_repo_list "$task"))
  _utm_suggest "${words[-1]}" "${repos[*]}" "${_UTM_REPO_REMOVE_FLAGS[*]}"
}


_utm_repo_remove_verify() {
  local task=$1
  shift
  local repos=("$@")

  _utm_log_debug "Verifying ${#repos[@]} repositories ..."

  # shellcheck disable=SC2207
  local task_repos=($(_utm_repo_list "$task"))

  for repo in "${repos[@]}"; do
    if ! _utm_in_array "$repo" "${task_repos[@]}"; then
      _utm_log_error "repo '$repo' is not included in '$task'!"
      return 1
    fi
  done

  return 0
}


_utm_repo_remove_single() {
  local task=$1
  local repo=$2

  local repo_location
  if ! repo_location=$(_utm_repo_dir_ensure "$task")/$repo; then
    return 1
  fi

  if ! rm -rf "$repo_location"; then
    _utm_log_error "Failed to remove '$repo_location' ... please remove manually"
  fi

  _utm_pipeline_remove_repo_links "$task" "$repo"
}


_utm_repo_remove() {
  local arg=$1

  local confirm=yes
  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --yes|-y)
        confirm=;;
      *)
        _utm_log_error "Invalid flag ... $arg"
        _utm_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  local task=$1
  shift
  local repos=("$@")

  if ! _utm_repo_remove_verify "$task" "${repos[@]}"; then
    return 1
  fi

  if [ -n "$confirm" ]; then
    if ! _utm_confirm "Are you sure you want to remove the repos '${repos[*]}' ?"; then
      return 1
    fi
  fi

  _utm_log_debug "Removing repos '${repos[*]}' from task '$task' ..."

  local repo
  local lf_remove
  lf_remove=
  for repo in "${repos[@]}"; do
    _utm_log_debug "removing repo '$repo' ..."

    _utm_repo_remove_single "$task" "$repo"

    if _utm_lf_verify_single "$repo"; then
      if _utm_lf_package_remove_single "$task" "$repo"; then
        lf_remove=yes
      fi
    fi
  done

  _utm_json_remove_repos "$task" "${repos[@]}"

  if [ -n "$lf_remove" ]; then
    _utm_log_debug "Writing out config file for task '$task' ..."
    _utm_pipeline_write_config "$task"
  fi
}
