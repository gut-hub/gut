#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_time_now" "_gut_time_parse")
GUT_EXPORT_NAMES=("now" "time")
GUT_EXPORT_DESCRIPTIONS=("Displays current time in UNIX timestamp" "Parse UNIX timestamp")

# Displays current time in unix timestamp
_gut_time_now() {
  local now=$(date +%s000)
  echo "${now}"
}

# Parses UNIX timestamp
_gut_time_parse() {
  local time=${1}

  # date only works in seconds
  if [[ "${#time}" -ge 13 ]]; then
    time=${time:0:10}
  fi

  local date=$(date -r ${time})
  echo "${date}"
}
