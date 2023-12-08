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
  local num_words
  local last_word
  num_words=${#COMP_WORDS[@]} 
  last_word=${COMP_WORDS[$num_words-2]}

  if [ "$last_word" == "$UTM_BASE_COMMAND" ]
  then
    COMPREPLY=($(compgen -W "${UTM_COMMANDS[*]}" "${COMP_WORDS[$num_words-1]}"))
    return
  fi

  local utm_loc
  utm_loc=$(_utm_location_in_array "$UTM_BASE_COMMAND" "${COMP_WORDS[@]}")
  if [ -n "$utm_loc" ]
  then
    local next_loc
    (("next_loc = $utm_loc + 1"))

    local command
    command=${COMP_WORDS[$next_loc]}

    case $command in
      "activate")
        COMPREPLY=($(_utm_activate_completions "${COMP_WORDS[@]:(($next_loc + 1))}"))
        return
    esac
  fi
}

function _utm_usage() {
  echo "Usage:"
  echo "======"
  echo "$UTM_BASE_COMMAND <command> <options>"
  echo 
  echo "Valid commands:"
  echo "---------------"
  local valid_command
  for valid_command in "${UTM_COMMANDS[@]}"
  do
    echo "$valid_command"
  done
}

function utm() {
  local command=$1
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
  echo $UTM_BASE_COMMAND "$command"
}

complete -F _utm_completions utm
