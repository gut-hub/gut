#!/usr/bin/env bash

# echo "hello" "world" | awk '{ printf "%-75s %-74s", $1, $2}'

_gut_column_get() {
  # lines=$(tput lines)
  # columns=$(tput cols)
  echo "$COLUMNS"
}

_gut_column_write() {
  local col_one=$1
  local col_two=$2

  # Set min and max
  local cols=$(_gut_column_get)
  let start=-1;
  let mid="${cols} / 2"

  # Output two column
  echo -en "\033[${start}C${col_one}"
  echo -en "\033[${mid}C${col_two}\n\r"
}
