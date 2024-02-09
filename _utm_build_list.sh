#!/bin/bash
#
#
# TODO: completions and usage


_UTM_BUILD_LIST_FLAGS=(
  "--links-only" "-l"
  "--dirs-only" "-d"
)


_utm_build_list_completions(){
  local words=("$@")
  local num_words=${#words[@]}

  if [[ $num_words -eq 1 ]]; then
    _utm_suggest "${words[0]}" "${_UTM_BUILD_LIST_FLAGS[*]}" "${_UTM_BUILD_LIST_FLAGS[*]}"
  fi
}


_utm_build_list() {
  local task=$1
  local arg=$2
  local links_only=
  local dirs_only=

  case $arg in
    --links-only|-l)
      links_only=1
      ;;
    --dirs-only|-d)
      dirs_only=1
      ;;
  esac

  local task_build_dir
  if ! task_build_dir=$(_utm_build_task_build_dir_ensure "$task"); then
    return 1
  fi

  local build_dir
  for build_dir in "$task_build_dir"/*; do
    if [[ -h "$build_dir" && -z "$dirs_only" ]]; then
      basename "$build_dir"
    elif [[ -d "$build_dir" && -z "$links_only" ]]; then
      basename "$build_dir"
    fi
  done
}


_utm_build_list_names() {
  local task=$1
  local builds

  readarray -t builds < <(_utm_build_list "$task" "-l")

  local name=
  for name in "${builds[@]}"; do
    if ! _utm_in_array "$name" "${_UTM_FORBIDDEN_BUILD_NAMES[@]}" ; then
      echo "$name"
    fi
  done
}
