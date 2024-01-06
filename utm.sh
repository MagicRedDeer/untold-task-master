#!/bin/bash
UTM_TASKDIR=${UTM_TASKDIR:-"$HOME/Workspace/UTM/Tasks"}
UTM_BUILD_DIR=${UTM_BUILD_DIR:-"$HOME/Workspace/UTM/Builds"}

_UTM_BASE_COMMAND=utm

_UTM_COMMANDS=(
  "create" "remove" "activate"
  "retire" "revive"
  "active" "list"
  "package" "build" "run"
  "repo" "lf" "config"
  "tmux" "attach"
  "dir" "cd"
)

_UTM_VERBOSE=
_UTM_FLAGS=(
  # for completions
  "--verbose" "-v"
  "--help" "-h"
)

_UTM_DIRECTORY=$(realpath "${BASH_SOURCE[0]}")
_UTM_DIRECTORY=$(dirname "$_UTM_DIRECTORY")

source "$_UTM_DIRECTORY/_utm_utils.sh"
source "$_UTM_DIRECTORY/_utm_create.sh"
source "$_UTM_DIRECTORY/_utm_activate.sh"
source "$_UTM_DIRECTORY/_utm_list.sh"
source "$_UTM_DIRECTORY/_utm_dir.sh"
source "$_UTM_DIRECTORY/_utm_remove.sh"
source "$_UTM_DIRECTORY/_utm_retire.sh"
source "$_UTM_DIRECTORY/_utm_revive.sh"
source "$_UTM_DIRECTORY/_utm_repo.sh"
source "$_UTM_DIRECTORY/_utm_lf.sh"
source "$_UTM_DIRECTORY/_utm_pipeline.sh"
source "$_UTM_DIRECTORY/_utm_json.sh"

function _utm_is_valid_command() {
  local delimiter=" "
  local command=$1
  echo "${_UTM_COMMANDS[*]}" | tr "$delimiter" '\n' | grep -F -q -x "$command"
}

function _utm_completions() {
  local utm_loc
  local next_loc
  local hint
  local num_words=${#COMP_WORDS[@]} 

  utm_loc=$(_utm_find "$_UTM_BASE_COMMAND" "${COMP_WORDS[@]}")

  # Base command not found this will probably never happen at runtime
  [ -z "$utm_loc" ] && return 1

  (("next_loc = $next_loc + 1"))
  hint=${COMP_WORDS[$next_loc]}

  while [ "$((next_loc + 1))" -lt "$num_words" ] ; do

    # if the next word is one of the commands kick it down the line
    case $hint in
      "activate")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_activate_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "dir")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_dir_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "cd")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_dir_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "remove")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_remove_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "list")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_list_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "retire")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_retire_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "revive")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_revive_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
      "repo")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_repo_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return $?;;
    esac

    # if its not one of the flags there is something wrong ... abort
    if ! _utm_in_array "$hint" "${_UTM_FLAGS[@]}"; then
      return 1
    fi

    _UTM_FLAGS=( "${_UTM_FLAGS[@]/$hint}" )

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${COMP_WORDS[$next_loc]}

  done

  # we have reached the last word provide completion now
  # shellcheck disable=SC2207
  COMPREPLY=($(_utm_suggest "$hint" "${_UTM_COMMANDS[*]}" "${_UTM_FLAGS[*]}"))
  return

}

function _utm_usage() {
  local s=${1:-info}
  _utm_echos "$s"
  _utm_echos "$s" "Usage:"
  _utm_echos "$s" "======"
  _utm_echos "$s" "$_UTM_BASE_COMMAND [$(_utm_join "|" "${_UTM_FLAGS[*]}")] <command> <options>"
  _utm_echos "$s" 
  _utm_echos "$s" "Valid commands:"
  _utm_echos "$s" "---------------"
  local valid_command
  for valid_command in "${_UTM_COMMANDS[@]}"
  do
    _utm_echos "$s" "$valid_command"
  done
  _utm_echos "$s"
}

function utm() {
  local arg=$1

  export _UTM_VERBOSE=

  # process options
  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --verbose|-v)
        export _UTM_VERBOSE=1;;
      --help|-h)
        _utm_usage "info"
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
    _utm_log_error "No valid command found ..."
    _utm_usage "error"
    return 0
  fi

  if ! _utm_is_valid_command "$1"
  then
    _utm_log_error "Invalid command ... $command"
    _utm_usage "error"
    return 1
  fi

  case $command in 
    "create")
      shift
      _utm_create "$@"
      return $?
      ;;
    "activate")
      shift
      _utm_activate "$@"
      return $?
      ;;
    "list")
      shift
      _utm_list "$@"
      return $?
      ;;
    "dir")
      shift
      _utm_dir "$@"
      return $?
      ;;
    "cd")
      shift
      _utm_cd "$@"
      return $?
      ;;
    "active")
      shift
      _utm_active "$@"
      return $?
      ;;
    "remove")
      shift
      _utm_remove "$@"
      return $?
      ;;
    "retire")
      shift
      _utm_retire "$@"
      return $?
      ;;
    "revive")
      shift
      _utm_revive "$@"
      return $?
      ;;
    "repo")
      shift
      _utm_repo "$@"
      return $?
      ;;
  esac

  _utm_log_error "$_UTM_BASE_COMMAND $command NOT IMPLEMENTED"
}

complete -F _utm_completions utm
