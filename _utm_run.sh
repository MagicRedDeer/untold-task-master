#!/bin/bash

_UTM_RUN_COMMANDS=()


_UTM_RUN_FLAGS=(
  "--task" "-t"
  "--help" "-h"
  "--name" "-n"
  "--python" "-p"
  "--log-level" "-l"
  "--job" "-j"
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
  local next_loc=0
  local hint=
  local num_words=${#words[@]}
  local task=
  local build_name=

  task=$(_utm_active)
  hint=${words[$next_loc]}


  while [ "$((next_loc + 1))" -lt "$num_words" ] ; do
    case "${hint}" in

      --task|-t)
        local tasks
        readarray -t tasks < <(_utm_list)

        # suggest task completions
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          _utm_suggest "${words[$next_loc + 1]}" "${tasks[*]}" ""
          return $?
        fi

        # check if task name is valid
        if ! _utm_in_array "${words[$next_loc + 1]}" "${tasks[@]}"; then
          return 1;
        fi

        task="${words[$next_loc + 1]}" 

        # skip the next word (task name)
        (("next_loc = $next_loc + 2"))
        hint=${words[$next_loc]}
        continue;;

      --name|-n)
        local builds
        readarray -t builds < <(_utm_build_list "$task")

        # suggest build completions
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          _utm_suggest "${words[$next_loc + 1]}" "${builds[*]}" ""
          return $?
        fi

        build_name="${words[$next_loc + 1]}" 

        # skip the next word (build name)
        (("next_loc = $next_loc + 2"))
        hint=${words[$next_loc]}
        continue;;

      --python|-p)

        # suggest task completions
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          _utm_suggest "${words[$next_loc + 1]}" "${_UTM_PYTHON_VERSIONS[*]}" ""
          return $?
        fi

        # check if python version is valid
        if ! _utm_in_array "${words[$next_loc + 1]}" "${_UTM_PYTHON_VERSIONS[@]}"; then
          return 1;
        fi

        # skip the next word (python version)
        (("next_loc = $next_loc + 2"))
        hint=${words[$next_loc]}
        continue;;

      --log-level|-l)

        # suggest task completions
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          _utm_suggest "${words[$next_loc + 1]}" "${_UTM_LOG_LEVELS[*]}" ""
          return $?
        fi

        # check if python version is valid
        if ! _utm_in_array "${words[$next_loc + 1]}" "${_UTM_LOG_LEVELS[@]}"; then
          return 1;
        fi

        # skip the next word (log level)
        (("next_loc = $next_loc + 2"))
        hint=${words[$next_loc]}
        continue;;

      --job|-j)
        local jobs
        readarray -t jobs < <(_utm_job_list "$task")

        # suggest task completions
        if [ "$((next_loc + 2))" == "$num_words" ]; then
          _utm_suggest "${words[$next_loc + 1]}" "${jobs[*]}" ""
          return $?
        fi

        # check if python version is valid
        if ! _utm_in_array "${words[$next_loc + 1]}" "${jobs[@]}"; then
          return 1;
        fi

        # skip the next word (log level)
        (("next_loc = $next_loc + 2"))
        hint=${words[$next_loc]}
        continue;;

    esac
    #
    # if its not one of the flags there is something wrong ... abort
    if ! _utm_in_array "$hint" "${_UTM_RUN_FLAGS[@]}"; then
      return 1
    fi

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${words[$next_loc]}

  done

  _utm_suggest "${hint}" "${_UTM_RUN_FLAGS[*]}" "${_UTM_RUN_FLAGS[*]}"
}


_utm_run () {
  local arg=$1
  local task=
  local build_name=
  local log_level=
  local python_version=
  local job_name

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
      --job|-j)
        shift
        job_name=$1
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
  _utm_log_debug "python version is: '$python_version'"

  local task_builds
  readarray -t task_builds < <(_utm_build_list "$task")
  if ! _utm_in_array "$build_name" "${task_builds[@]}" ; then
    _utm_log_error "invalid build name: '$build_name'"
    return 1
  fi

  if [ -n "$job_name" ]; then
    local jobs
    readarray -t jobs < <(_utm_job_list)
    if ! _utm_in_array "$job_name" "${jobs[@]}" ; then
      _utm_log_error "invalid job name: '$job_name' !"
      return 1
    fi
  fi

  _utm_run_perform "$task" "$build_name" "$python_version" "$log_level" "$job_name" "$@"
}


_utm_run_perform () (
  local task=$1
  local build_name=${2:-live}
  local required_py_version=${3:-"3.7.10"}
  local log_level=${4:-"info"}
  local job_name=${5:-""}
  shift 5 

  _utm_log_debug

  local UNTOLD_DEV_PIPELINE_ROOT
  UNTOLD_DEV_PIPELINE_ROOT="$UTM_BUILD_DIR/$task/$build_name"

  _utm_log_debug UNTOLD_DEV_PIPELINE_ROOT="$UNTOLD_DEV_PIPELINE_ROOT"
  export UNTOLD_DEV_PIPELINE_ROOT

  if [ -n "$job_name" ]; then
    _utm_log_debug cd "/jobs/$job_name"
    cd "/jobs/$job_name" || exit 1
  fi
  _utm_log_debug source /users/.default/untold_shell/untold_env/untold_env true true true "" "" "" "$required_py_version"
  source /users/.default/untold_shell/untold_env/untold_env true true true "" "" "" "$required_py_version"

  _utm_log_debug UNTOLD_LOGGING_LEVEL="$log_level"
  export UNTOLD_LOGGING_LEVEL=$log_level

  local command=
  local val

  for val in "$@"; do
    if [ -n "$command" ]; then
      command="$command \"$val\""
    else
      command="\"$val\""
    fi
  done

  _utm_log_debug executing "$command" ...
  eval "$command"
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


_utm_job_list() {
  local job
  for job in /jobs/*; do
    basename "$job"
  done
}
