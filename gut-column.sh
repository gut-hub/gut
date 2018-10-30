#!/usr/bin/env bash

# Retrieves the number of column characters
_gut_column_get() {
  # lines=$(tput lines)
  # columns=$(tput cols)
  echo "${COLUMNS}"
}

# Display the input in column format
# @param {string} col_one - First column
# @param {string} col_two - Second column
# @param {string} col_mid - Whitespace offset between columns
_gut_column_echo() {
  local col_one=${1}
  local col_two=${2}
  local col_mid=${3}

  # get columns
  local cols=$(_gut_column_get)
  let start=-1;
  let one="${#col_one}"
  let two="${#col_two}"
  let mid="${col_mid}"
  let dif=(mid - one)

  # Output column
  echo -en "\033[${start}C${col_one}"
  echo -en "\033[${dif}C${col_two}\n\r"
}
