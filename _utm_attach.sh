#!/bin/bash


_UTM_ATTACH_COMMAND=attach


_UTM_ATTACH_FLAGS=(
  "--task" "-t"
  "--help" "-h"
)


source "$_UTM_DIRECTORY/_utm_tmux.sh"


_utm_attach_completions() {
  local words=("$@")  
  local next_loc=0
  local hint
  local num_words=${#words[@]}
  local task

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
    esac
    
    # if its not one of the flags there is something wrong ... abort
    if ! _utm_in_array "$hint" "${_UTM_ATTACH_FLAGS[@]}"; then
      return 1
    fi

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${words[$next_loc]}

  done

  _utm_suggest "${hint}" "${_UTM_ATTACH_FLAGS[*]}" "${_UTM_ATTACH_FLAGS[*]}"
}


_utm_attach_usage() {
  local s=${1:-info}
  _utm_echos "$s"
  _utm_echos "$s" "Usage:"
  _utm_echos "$s" "======"
  _utm_echos "$s" "$_UTM_BASE_COMMAND [$(_utm_join "|" "${_UTM_FLAGS[*]}")] \
    $_UTM_ATTACH_COMMAND <options>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_ATTACH_COMMAND flags:"
  _utm_echos "$s" "---------------"
  _utm_echos "$s" "--help|-h"
  _utm_echos "$s" "--task|-t" "<task>"
  _utm_echos "$s" "---------------"
}


_utm_attach () {
  _utm_log_debug "Executing $_UTM_BASE_COMMAND $_UTM_ATTACH_COMMAND ..."
  local arg=$1
  local task_name=

  while [[ "$arg" =~ ^- ]]; do
    case $arg in
      --task|-t)
        shift
        task_name=$1
        ;;
      --help|-h)
        _utm_attach_usage "info"
        return 0;;
      *)
        _utm_log_error "Invalid argument ... $arg"
        _utm_attach_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  if [ -z "$task_name" ]; then
    _utm_log_debug "No task provided ... defaulting to active task!"
    task_name=$(_utm_active 2> /dev/null)
  fi

  _utm_log_debug task_name is "'$task_name'" !

  if ! _utm_task_check_live "$task_name"; then
    # the above function also prints the error so no need to print here
    return 1
  fi

  _utm_tmux_attach "$task_name"
}
