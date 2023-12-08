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

function utm() {
  echo "Welcome to UTM"
  echo $UTM_BASE_COMMAND "$*"
}

complete -F _utm_completions utm
