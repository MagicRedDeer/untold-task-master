#!/bin/bash


_UTM_BUILD_COMMANDS=(
  "add"
  "remove"
  "dir"
  "ll"
  "list"
)


_UTM_BUILD_FLAGS=(
  "--task" "-t"
  "--help" "-h"
  "--name" "-n"
)


_UTM_BUILD_COMMAND=build


source "$_UTM_DIRECTORY/_utm_build_add.sh"
source "$_UTM_DIRECTORY/_utm_build_list.sh"


_utm_build_completions () {
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

      add)
        _utm_build_add_completions "${task:="$(_utm_active)"}" "$build_name" "${words[@]:1}"
        return $?;;

      list)
        _utm_build_list_completions "${words[@]:1}"
        return $?;;

      # remove)
      #   _utm_build_remove_completions "${task:="$(_utm_active)"}" "$build_name" "${words[@]:1}"
      #   return $?;;

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
        readarray -t builds < <(_utm_build_list_names "$task")

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
    esac
    
    # if its not one of the flags there is something wrong ... abort
    if ! _utm_in_array "$hint" "${_UTM_BUILD_FLAGS[@]}"; then
      return 1
    fi

    # take up the next word
    (("next_loc = $next_loc + 1"))
    hint=${words[$next_loc]}

  done

  _utm_suggest "${hint}" "${_UTM_BUILD_COMMANDS[*]}" "${_UTM_BUILD_FLAGS[*]}"
}


_utm_build_usage() {
  local s=${1:-info}
  _utm_echos "$s"
  _utm_echos "$s" "Usage:"
  _utm_echos "$s" "======"
  _utm_echos "$s" "$_UTM_BASE_COMMAND [$(_utm_join "|" "${_UTM_FLAGS[*]}")] \
    $_UTM_BUILD_COMMAND <options> <command>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND flags:"
  _utm_echos "$s" "---------------"
  _utm_echos "$s" "--help|-h"
  _utm_echos "$s" "--task|-t" "<task>"
  _utm_echos "$s" "--name|n" "<name>"
  _utm_echos "$s" 
  _utm_echos "$s" "$_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND commands:"
  _utm_echos "$s" "---------------"
  local valid_command
  for valid_command in "${_UTM_BUILD_COMMANDS[@]}"
  do
    _utm_echos "$s" "$valid_command"
  done
  _utm_echos "$s"
}


_utm_build() {
  _utm_log_debug "Executing $_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND ..."
  local arg=$1
  local task=
  local build_name=

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
      --help|-h)
        _utm_build_usage "info"
        return 0;;
      *)
        _utm_log_error "Invalid argument ... $arg"
        _utm_build_usage "error"
        return 1
        ;;
    esac
    shift
    arg=$1
  done

  local command=$1
  if [ -z "$command" ]; then
    _utm_log_error "No valid '$_UTM_BUILD_COMMAND' command found ..."
    _utm_build_usage "error"
    return 0
  fi

  if ! _utm_in_array "$command" "${_UTM_BUILD_COMMANDS[@]}"
  then
    _utm_log_error "Invalid '$_UTM_BUILD_COMMAND' command ... $command"
    _utm_build_usage "error"
    return 1
  fi

  if [ -z "$task" ]; then
    _utm_log_debug "No task provided ... defaulting to active task!"
    task=$(_utm_active 2> /dev/null)
  fi

  _utm_log_debug task is "'$task'" !
  if [ -n "$build_name" ]; then
    _utm_log_debug "build name is: '$build_name' !"
  fi

  if ! _utm_task_check_live "$task"; then
    # the above function also prints the error so no need to print here
    return 1
  fi

  case $command in 

    "add")
      shift
      _utm_build_add "$task" "$build_name" "$@"
      return $?
      ;;

    "dir")
      _utm_build_task_build_dir_ensure "$task"
      return $?
      ;;

    "ll")
      ll "$(_utm_build_task_build_dir_ensure "$task")"
      return $?
      ;;
     
    # "remove")
    #   shift
    #   _utm_build_remove "$task" "$build_name" "$@"
    #   return $?
    #   ;;

    "list")
      shift
      _utm_build_list "$task" "$@"
      return $?
      ;;

  esac

  _utm_log_error "$_UTM_BASE_COMMAND $_UTM_BUILD_COMMAND $command NOT IMPLEMENTED!!"
}


_utm_build_remove_completions() {
  echo "nothing goes here" "$@"
}


_utm_build_remove() {
  echo "utm build remove ... placeholder with args: $*"
}


_utm_build_task_build_dir_ensure() {
  local task=$1

  local task_build_dir="$UTM_BUILD_DIR"/"$task"
  mkdir -p "$task_build_dir" > /dev/null
  
  local task_pipeline_dir
  if ! task_pipeline_dir=$(_utm_pipeline_ensure_base_dir "$task"); then
    return 1
  fi

  ln -s -f -T "$task_pipeline_dir" "$task_build_dir/live"

  echo "$task_build_dir"
}

