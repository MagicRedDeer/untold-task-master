#!/bin/bash
UTM_TASKDIR=${UTM_TASKDIR:-"~/Workspace/Tasks"}
UTM_BUILD_DIR=${UTM_BUILD_DIR:-"$HOME/.task_builds"}

_utm_get_python_full_version () {
  local python_version
  read -ra python_version <<<"$(python --version)"
  echo "${python_version[1]}"
}

_utm_task_list(){
  local name
  for name in "$UTM_TASKDIR"/*; do
    [ -d "$name" ] || continue
    basename "$name"
  done
}

_utm_task_is_valid() {
  local tasks
  tasks=$(_utm_task_list)
  echo "$tasks" | tr " " '\n' | grep -F -q -x "$1"
}

_utm_task_create() {

  local taskname="$1"
  if _utm_task_is_valid "$taskname"; then
    echo "task $taskname already exists"
    return 1
  fi

  local template="${UTM_TASKDIR}"/.task_template
  if [ ! -d "$template" ]; then
    echo "Directory $template Not Found!"
    return 1
  fi

  local taskdir
  taskdir=$UTM_TASKDIR/$taskname
  mkdir -p "$taskdir" > /dev/null
  mkdir -p "$taskdir/python"
  touch "$taskdir/python/_scrap.py"

  echo ln -T "${template}/task_manage" "${taskdir}/task_manage"
  ln -T "${template}/task_manage" "${taskdir}/task_manage"

  chmod u+x "${taskdir}/task_manage"
  cp "${template}/pyrightconfig.json" "$taskdir/pyrightconfig.json" > /dev/null
  _get_python_full_version > "$taskdir/python_version"
  task_activate "$taskname"
}

_utm_task_activate() {
  local taskname="$1"
  if task_is_valid "$taskname"; then
    "$UTM_TASKDIR/$taskname/task_manage" activate
  else
    echo "$taskname is invalid"
    return 1
  fi
  task_goto "$taskname"
}

function _utm_completions() {
  greetings=("hello" "hi" "salaam")
  objects=("fazila jamila gazeela kafeela")
  if [ "${#COMP_WORDS[@]}" == "2" ]; then
    COMPREPLY=($(compgen -W "${greetings[*]}" "${COMP_WORDS[1]}"))
  elif [ "${#COMP_WORDS[@]}" == "3" ]; then
    if [[ "${greetings[@]}" =~ "${COMP_WORDS[1]}" ]]; then
      COMPREPLY=($(compgen -W "${objects[*]}" "${COMP_WORDS[2]}"))
    fi
  fi
  
}

function utm() {
  echo "Welcome to the Untold Task Master"
  echo "$1 dear $2!"
}

complete -F _utm_completions utm
