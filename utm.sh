#!/bin/bash
UTM_TASKDIR=${UTM_TASKDIR:-"~/Workspace/Tasks"}
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

source "$UTM_DIRECTORY/_utm_create.sh"

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
  esac
  echo $UTM_BASE_COMMAND "$command"
}

complete -F _utm_completions utm
