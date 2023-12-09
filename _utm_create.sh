#!/bin/bash

_utm_create() {
  _utm_info "utm create from inside source file"
  _utm_info "$UTM_BASE_COMMAND" create "$*"
}
