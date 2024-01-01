#!/bin/bash

_UTM_REPO_COMMANDS=(
  "add"
  "remove"
  "list"
  "create"
)

_UTM_REPO_FLAGS=(
  "--task" "-t"
  "--help" "-h"
)

_UTM_REPO_COMMAND=repo
_UTM_REPO_DIRNAME=repos

source "$_UTM_DIRECTORY/_utm_repo_add.sh"

_utm_repo_completions() {
  local words=("$@")  
  local next_loc=0
  local hint
  local num_words=${#words[@]}

  hint=${words[$next_loc]}

  while [ "$((next_loc + 1))" -lt "$num_words" ] ; do
    case "${hint}" in
      add)
        _utm_repo_add_completions "${words[@]:1}"
        return $?;;
      --task|-t)
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          local tasks
          # shellcheck disable=SC2207
          tasks=($(_utm_list))
          _utm_suggest "${words[$next_loc + 1]}" "${tasks[*]}" ""
          return $?
        fi
        ;;
    esac

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${words[$next_loc]}

  done

  _utm_suggest "${hint}" "${_UTM_REPO_COMMANDS[*]}" "${_UTM_REPO_FLAGS[*]}"
}

function _utm_repo_usage() {
  local s=${1:-info}
  _utm_echos "$s"
  _utm_echos "$s" "Usage:"
  _utm_echos "$s" "======"
  _utm_echos "$s" "$_UTM_BASE_COMMAND [$(_utm_join "|" "${_UTM_FLAGS[*]}")] \
    $_UTM_REPO_COMMAND <options> <command>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_REPO_COMMAND flags:"
  _utm_echos "$s" "---------------"
  _utm_echos "$s" --help -h
  _utm_echos "$s" --task "<task>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_REPO_COMMAND commands:"
  _utm_echos "$s" "---------------"
  local valid_command
  for valid_command in "${_UTM_REPO_COMMANDS[@]}"
  do
    _utm_echos "$s" "$valid_command"
  done
  _utm_echos "$s"
}

_utm_repo() {
  _utm_log_debug "Executing $_UTM_BASE_COMMAND $_UTM_REPO_COMMAND ..."
  local arg=$1
  local task_name=

  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --task|-t)
        shift
        task_name=$1
        ;;
      --help|-h)
        _utm_repo_usage "info"
        return 0;;
      *)
        _utm_log_error "Invalid argument ... $arg"
        _utm_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  # process commands
  local command=$1
  if [ -z "$command" ]; then
    _utm_log_error "No valid '$_UTM_REPO_COMMAND' command found ..."
    _utm_repo_usage "error"
    return 0
  fi

  if ! _utm_in_array "$command" "${_UTM_REPO_COMMANDS[@]}"
  then
    _utm_log_error "Invalid '$_UTM_REPO_COMMAND' command ... $command"
    _utm_repo_usage "error"
    return 1
  fi

  if [ -z "$task_name" ]; then
    _utm_log_debug "No task provided ... defaulting to active task!"
    task_name=$(_utm_active 2> /dev/null)
  fi

  _utm_log_debug task_name is "'$task_name'" !

  if ! _utm_task_check_live "$task_name"; then
    # the above function also prints the error so no need to print here
    return 1
  fi

  case $command in 

    "add")
      shift
      _utm_repo_add "$task_name" "$@"
      return $?
      ;;

    "remove")
      shift
      _utm_repo_remove "$task_name" "$@"
      return $?
      ;;

    "list")
      shift
      _utm_repo_list "$task_name" "$@"
      return $?
      ;;

  esac

  _utm_log_error "$_UTM_BASE_COMMAND $_UTM_REPO_COMMAND $command NOT IMPLEMENTED!!"
}

_utm_repo_remove() {
  local task=$1
  shift
  local repos=("$@")
  _utm_log_info "Removing repo" "${repos[@]}" in "'$task'"...
}

_utm_repo_list() {
  local task=$1
  _utm_log_info "listing all repos in '$task'..."
}
