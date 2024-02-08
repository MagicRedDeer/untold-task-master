#!/bin/bash

_UTM_RUN_COMMANDS=()


_UTM_RUN_FLAGS=(
  "--task" "-t"
  "--help" "-h"
  "--name" "-n"
  "--python" "-p"
  "--log-level" "-l"
)

_UTM_LOG_LEVELS=(
  notset
  debug
  info
  warning
  error
  critical
)

_UTM_RUN_COMMAND=run


_utm_run_completions () {
  local words=("$@")
}


_utm_run () {
  local arg=$1
  local task=
  local build_name=
  local log_level=
  local python_version=

  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --task|-t)
        shift
        task=$1
        ;;
      --name|-n)
        shift
        build_name=$1
        ;;
      --log-level|-l)
        shift
        log_level=$1
        ;;
      --python|-p)
        shift
        python_version=$1
        ;;
      --help|-h)
        _utm_run_usage "info"
        return 0;;
      *)
        _utm_log_error "Invalid argument ... $arg"
        _utm_run_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  if [ -z "$task" ]; then
    _utm_log_debug "No task provided ... defaulting to active task!"
    task=$(_utm_active 2> /dev/null)
  fi
  _utm_log_debug task is "'$task'" !

  if [ -z "$build_name" ]; then
    _utm_log_debug "No build name provided ... defaulting to live!"
    build_name=live
  fi
  _utm_log_debug "build name is: '$build_name' !"

  if [ -n "$log_level" ]; then
    if ! _utm_in_array "$log_level" "${_UTM_LOG_LEVELS[@]}" ; then
      _utm_log_error "invalid log-level value: '$log_level'"
      return 1
    fi
    _utm_log_debug "log level is: '$log_level'"
  fi

  if [ -n "$python_version" ]; then
    if ! _utm_in_array "$python_version" "${_UTM_PYTHON_VERSIONS[@]}" ; then
      _utm_log_error "invalid python version: '$python_version'" "${_UTM_PYTHON_VERSIONS[@]}" 
      return 1
    fi
    _utm_log_debug "python version is: '$python_version'"
  fi

  local task_builds=($(_utm_build_list "$task"))
  if ! _utm_in_array "$build_name" "${task_builds[@]}" ; then
    _utm_log_error "invalid build name: '$build_name'"
    return 1
  fi

  _utm_run_perform "$task" "$build_name" "$python_version" "$log_level" "$@"
}


_utm_run_perform () (
  local task=$1
  local build_name=${2:-live}
  local python_version=${3:-"3.7.10"}
  local log_level=${4:-"info"}
  shift 4 

  local UNTOLD_DEV_PIPELINE_ROOT
  UNTOLD_DEV_PIPELINE_ROOT=$(readlink "$UTM_BUILD_DIR/$task/$build_name")
  export UNTOLD_DEV_PIPELINE_ROOT
  source /users/.default/untold_shell/untold_env/untold_env \
    true true true "" "" "" "$python_version"
  export UNTOLD_LOGGING_LEVEL=$log_level
  "$@"
)


_utm_run_usage() {
  local s=${1:-info}
  _utm_echos "$s"
  _utm_echos "$s" "Usage:"
  _utm_echos "$s" "======"
  _utm_echos "$s" "$_UTM_BASE_COMMAND [$(_utm_join "|" "${_UTM_FLAGS[*]}")] \
    $_UTM_RUN_COMMAND <options> <command>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND flags:"
  _utm_echos "$s" "---------------"
  _utm_echos "$s" "--help|-h"
  _utm_echos "$s" "--task|-t" "<task>"
  _utm_echos "$s" "--name|-n"  "<name>"
  _utm_echos "$s" "--log-level|-l" "$(_utm_join "|" "${_UTM_LOG_LEVELS[*]}")"
  _utm_echos "$s" "--python|-p" "$(_utm_join "|" "${_UTM_PYTHON_VERSIONS[*]}")"
  # _utm_echos "$s" 
  # _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND commands:"
  _utm_echos "$s" "---------------"
  local valid_command
  for valid_command in "${_UTM_BUILD_COMMANDS[@]}"
  do
    _utm_echos "$s" "$valid_command"
  done
  _utm_echos "$s"
}
