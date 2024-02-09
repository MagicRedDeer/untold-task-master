#!/bin/bash


_utm_tmux_ensure () {
  local task=$1
  local task_dir="$UTM_TASKDIR/$task"

  _utm_log_debug "Ensuring tmux session '$task' ..."

  pushd "$task_dir" > /dev/null || exit 1
  tmux has-session -t "$task" 2> /dev/null || tmux new -d -s "$task"
  popd > /dev/null || exit 1
}


_utm_tmux_attach () {
  local task=$1
  _utm_tmux_ensure "$task"
  _utm_log_debug "attaching to tmux session '$task' ..."

  tmux a -t "$task"
}

