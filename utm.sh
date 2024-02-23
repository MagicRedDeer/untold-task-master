#!/bin/bash
UTM_TASKDIR=${UTM_TASKDIR:-"$HOME/Workspace/UTM/Tasks"}
UTM_BUILD_DIR=${UTM_BUILD_DIR:-"$HOME/Workspace/UTM/Builds"}


_UTM_BASE_COMMAND=utm


_UTM_COMMANDS=(
  "create"
  "remove" "rm" "delete"
  "activate" "make_active"
  "retire"
  "revive"
  "active" "current"
  "list" "ls"
  "repo" "package"
  "dir" "homedir"
  "cd" "chdir" "pushd"
  "build"
  "run"
  "attach"
  "config"
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
source "$_UTM_DIRECTORY/_utm_build.sh"
source "$_UTM_DIRECTORY/_utm_run.sh"
source "$_UTM_DIRECTORY/_utm_attach.sh"
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
      "create"|"c")
        readarray -t COMPREPLY < <(_utm_create_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "activate"|"make_active"|"ma")
        readarray -t COMPREPLY < <(_utm_activate_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "dir"|"homedir")
        readarray -t COMPREPLY < <(_utm_dir_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "cd"|"chdir")
        readarray -t COMPREPLY < <(_utm_dir_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "pushd")
        readarray -t COMPREPLY < <(_utm_dir_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "remove"|"rm"|"delete"|"del")
        readarray -t COMPREPLY < <(_utm_remove_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "list"|"ls")
        readarray -t COMPREPLY < <(_utm_list_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "retire")
        readarray -t COMPREPLY < <(_utm_retire_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "revive")
        readarray -t COMPREPLY < <(_utm_revive_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "repo"|"repos"|"package")
        readarray -t COMPREPLY < <(_utm_repo_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "build"|"b")
        readarray -t COMPREPLY < <(_utm_build_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "run"|"r")
        readarray -t COMPREPLY < <(_utm_run_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
      "attach"|"a")
        readarray -t COMPREPLY < <(_utm_attach_completions "${COMP_WORDS[@]:(($next_loc + 1))}")
        return $?;;
    esac

    # if its not one of the flags there is something wrong ... abort
    if ! _utm_in_array "$hint" "${_UTM_FLAGS[@]}"; then
      return 1
    fi

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${COMP_WORDS[$next_loc]}

  done

  # we have reached the last word provide completion now
  readarray -t COMPREPLY < <(_utm_suggest "$hint" "${_UTM_COMMANDS[*]}" "${_UTM_FLAGS[*]}")
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

  case $command in 
    "create"|"c")
      shift
      _utm_create "$@"
      return $?
      ;;
    "activate"|"make_active"|"ma")
      shift
      _utm_activate "$@"
      return $?
      ;;
    "list"|"ls")
      shift
      _utm_list "$@"
      return $?
      ;;
    "dir")
      shift
      _utm_dir "$@"
      return $?
      ;;
    "cd"|"chdir")
      shift
      _utm_cd "$@"
      return $?
      ;;
    "pushd")
      shift
      _utm_pushd "$@"
      return $?
      ;;
    "active"|"current")
      shift
      _utm_active "$@"
      return $?
      ;;
    "remove"|"rm"|"delete"|"del")
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
    "repo"|"repos"|"package")
      shift
      _utm_repo "$@"
      return $?
      ;;
    "build"|"b")
      shift
      _utm_build "$@"
      return $?
      ;;
    "run"|"r")
      shift
      _utm_run "$@"
      return $?
      ;;
    "attach"|"a")
      shift
      _utm_attach "$@"
      return $?
      ;;
    "config")
      _utm_log_error "$_UTM_BASE_COMMAND $command NOT IMPLEMENTED"
      return 1
      ;;
    *)
      _utm_log_error "Invalid command ... '$command'"
      _utm_usage "error"
      return 1
  esac
}

complete -F _utm_completions utm
