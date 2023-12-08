#!/bin/bash

_utm_list() {
  local name
  for name in "$UTM_TASKDIR"/*
  do
    [ "$name" != "$UTM_TASKDIR/CurrentTask" ] || continue
    [ -d "$name" ] || continue
    basename "$name"
  done
}
