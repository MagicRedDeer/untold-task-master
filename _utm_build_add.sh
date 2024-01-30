#!/bin/bash


_utm_build_add_completions() {
  echo "nothing goes here" $@
}

_utm_build_add() {
  local task=$1
  local build_name=$2

  case "$build_name" in
    "latest"|"live")
      build_name=;;
  esac

  if [[ "$build_name" =~ ^- ]]; then
    build_name=
  fi

  local task_build_dir
  if ! task_build_dir=$(_utm_build_task_build_dir_ensure "$task"); then
    return 1
  fi

  local date_str
  date_str=$(date +"%Y.%m.%d_%H.%M.%S")
  local build_dir
  build_dir=${task_build_dir}/${date_str}


  if [ -d "$build_dir" ]; then
    _utm_log_debug "Removing existing dir: $build_dir ..."
    rm -rf "$build_dir"
  fi
  mkdir -p "$build_dir" > /dev/null

  _utm_lf_build "$task" "$build_dir"

  _utm_log_debug "Setting read and execute permissions ..."
  chmod -R 755 "$build_dir"

  _utm_log_debug "Linking '$build_dir' as latest build ..."
  ln -s -f -T "./$date_str" "$task_build_dir/latest"

  if [ -n "$build_name" ]; then
    _utm_log_debug "Linking '$build_name' to './$date_str' ..."
    ln -s -f -T "./$date_str" "$task_build_dir/$build_name"
  fi
}
