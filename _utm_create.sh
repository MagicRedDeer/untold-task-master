#!/bin/bash

_utm_create() {
  echo "utm create from inside source file"
  echo "$UTM_BASE_COMMAND" create "$*"
}
