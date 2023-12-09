#!/bin/bash
UTM_TASKDIR=${UTM_TASKDIR:-"$HOME/Workspace/Tasks"}
UTM_BUILD_DIR=${UTM_BUILD_DIR:-"$HOME/.task_builds"}
UTM_BASE_COMMAND=utm
UTM_COMMANDS=(
  "create"
  "remove"
  "activate"
  "retire"
  "revive"
  "active"
  "list"
  "package"
  "build"
  "run"
  "repo"
  "lf"
  "config"
  "tmux"
  "attach"
  "dir"
  "cd"
)

UTM_VERBOSE=
UTM_FLAGS=(
  "--verbose" "-v"
  "--help" "-h"
)

UTM_DIRECTORY=$(realpath "${BASH_SOURCE[0]}")
UTM_DIRECTORY=$(dirname "$UTM_DIRECTORY")

source "$UTM_DIRECTORY/_utm_utils.sh"
source "$UTM_DIRECTORY/_utm_create.sh"
source "$UTM_DIRECTORY/_utm_activate.sh"
source "$UTM_DIRECTORY/_utm_list.sh"

function _utm_is_valid_command() {
  local delimiter=" "
  local command=$1
  echo "${UTM_COMMANDS[*]}" | tr "$delimiter" '\n' | grep -F -q -x "$command"
}

function _utm_completions() {
  local utm_loc
  local next_loc
  local command
  local num_words=${#COMP_WORDS[@]} 

  utm_loc=$(_utm_location_in_array "$UTM_BASE_COMMAND" "${COMP_WORDS[@]}")

  # Base command not found this will probably never happen at runtime
  [ -z "$utm_loc" ] && return 1

  (("next_loc = $next_loc + 1"))
  command=${COMP_WORDS[$next_loc]}

  while [ "$((next_loc + 1))" -lt "$num_words" ] ; do

    # if the next word is one of the commands kick it down the line
    case $command in
      "activate")
        # shellcheck disable=SC2207
        COMPREPLY=($(_utm_activate_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return
    esac

    # if its not one of the flags there is something wrong ... abort
    if ! _utm_obj_is_in_array "$command" "${UTM_FLAGS[@]}"; then
      COMPREPLY=(NO FLAGS)
      return
    fi

    # take up the next word
    (("next_loc = $next_loc + 1"))
    command=${COMP_WORDS[$next_loc]}

  done

  # we have reached the last word provide completion now
  if [[ "$command" =~ ^- ]]; then
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${UTM_FLAGS[*]}" -- "${command}"))  # flags
    return
  else  # complete commands
    # shellcheck disable=SC2207
    COMPREPLY=($(compgen -W "${UTM_COMMANDS[*]}" "${command}"))
    return
  fi
}

function _utm_usage() {
  echo
  echo "Usage:"
  echo "======"
  echo "$UTM_BASE_COMMAND [--verbose|-v] <command> <options>"
  echo 
  echo "Valid commands:"
  echo "---------------"
  local valid_command
  for valid_command in "${UTM_COMMANDS[@]}"
  do
    echo "$valid_command"
  done
  echo
}

function utm() {
  local arg=$1

  # process options
  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --verbose|-v)
        export UTM_VERBOSE=1;;
      --help|-h)
        _utm_usage
        return 0;;
      *)
        export UTM_VERBOSE=
        echo "ERROR: invalid argument ... $arg"
        _utm_usage
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  # process commands
  local command=$1
  if [ -z "$command" ]; then
    echo "ERROR: No valid command found ..."
    _utm_usage
    return 0
  fi

  if ! _utm_is_valid_command "$1"
  then
    echo "ERROR: Invalid command ... $command"
    echo
    _utm_usage
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
  esac

  echo $UTM_BASE_COMMAND "$command" NOT IMPLEMENTED
}

complete -F _utm_completions utm
