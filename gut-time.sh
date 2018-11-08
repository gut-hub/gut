#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_time_now")
GUT_EXPORT_NAMES=("now")
GUT_EXPORT_DESCRIPTIONS=("Displays current time in unix timestamp")

# Displays current time in unix timestamp
_gut_time_now() {
  local now=$(date +%s000)
  echo "${now}"
}
