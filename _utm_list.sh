#!/bin/bash

_utm_list() {
  local name
  for name in "$UTM_TASKDIR"/*
  do
    [ "$name" != "$UTM_TASKDIR/$_UTM_ACTIVE_TASK" ] || continue
    [ -d "$name" ] || continue
    [ -f "$name/$_UTM_JSON_FILENAME" ] || continue
    basename "$name"
  done
}
