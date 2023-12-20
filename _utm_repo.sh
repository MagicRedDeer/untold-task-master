#!/bin/bash

_UTM_REPO_COMMANDS=(
  "add"
  "remove"
  "list"
  "create"
)

_UTM_REPO_FLAGS=(
  "--task"
  "--help" "-h"
)

_UTM_REPO_COMMAND=repo
_UTM_REPO_DIRNAME=repos

_utm_repo_completions() {
  local words=("$@")  
  local num_words=${#words[@]}

  if [ "$num_words" -eq 1 ]; then
    _utm_suggest "${words[0]}" "${_UTM_REPO_COMMANDS[*]}" "${_UTM_REPO_FLAGS[*]}"
  fi
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
      --task)
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
    return 1
  fi

  case $command in 

    "add")
      shift
      _utm_repo_create "$task_name" "$@"
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

_utm_repo_add() {
  local task=$1
  shift
  local repos=("$@")
  _utm_log_info "Adding repos " "${repos[@]}" in "'$task'"...
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
