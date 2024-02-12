#!/bin/bash

UTM_TASKDIR=$HOME/Workspace/Tasks
UTM_BUILD_DIR=$HOME/.task_builds


source utm.sh

_UTM_VERBOSE=


_convert_all () {
  local tasks
  readarray -t tasks < <(task_list)

  for task in "${tasks[@]}"; do
    [ "$task" = "CurrentTask" ] && continue
    if _utm_task_is_valid "$task"; then
      continue
    fi
    _convert_task "$task"
  done
}


_convert_task() {
  local task=$1
  local task_dir="$UTM_TASKDIR/$task"
  local json_file_path="$task_dir/$_UTM_JSON_FILENAME"
  echo converting "$task" ...
  _utm_json_initialize "$task" "$json_file_path" 

  local repos
  local newrepoloc
  repos=()
  for repo in "$task_dir"/el7-x86-64/*/*; do
    [ -d "$repo" ] || continue
    repo_bn=$(basename "$repo")
    repos+=("$repo_bn")
    newrepoloc="$task_dir/includes/$repo_bn"
    mkdir -p "$(dirname "$newrepoloc")"
    mv "$repo" "$newrepoloc"
    _utm_pipeline_create_repo_links "$task" "$repo_bn" "$newrepoloc"
  done

  _utm_json_add_repos "$task" "${repos[@]}"
  _utm_lf_package_add "$task"  "${repos[@]}"
  _utm_pipeline_write_config "$task"
}
