#!/usr/bin/env bash

# Vars
_GUT_MENU_COLOR() {
  echo "\033[0;$(_gut_color_get_env)m"
}
# _GUT_MENU_COLOR="\033[0;31m"
_GUT_MENU_RESET="\033[0m"

# Display menu with user input
# @param {array} elements - Array of strings containing items to display
# @return {string} index - Selected array index
_gut_menu() {
  # Get array
  declare -a array=("${!1}")

  # Set mix and max
  let i=0;
  let min=0;
  let max="${#array[@]} - 1"

  # Turn off terminal cursor
  echo -en "\033[?25l"

  while true
  do
    # User input logic
    if [ "${input}" = "A" ]; then
      if [ "${i}" -gt "${min}" ]; then
        (( i -= 1 ))
      fi
    fi
    if [ "${input}" = "B" ]; then
      if [ "${i}" -lt "${max}" ]; then
        (( i += 1 ))
      fi
    fi

    # Echo menu
    _gut_menu_echo array[@] ${i}

    # Read user input
    read -r -sn1 input

    # Read selection (This is after read to prevent early termination)
    if [ "${input}" = "" ]; then
      break
    fi

    # Clear menu
    _gut_menu_clear array[@]
  done

  # Turn on terminal cursor
  echo -en "\033[?25h"

  return ${i}
}

# Draws the menu
# @param {array} elements - Array of strings containing items to display
# @param {string} index - Selected array index
_gut_menu_echo() {
  # Get array
  declare -a array=("${!1}")

  # Iterate over array
  for k in "${!array[@]}"; do
    if [ "${2}" -eq "${k}" ]; then
      # Echo selection
      echo -en "$(_GUT_MENU_COLOR)${array[$k]} \n \r"
    else
      # Echo unselected
      echo -en "${_GUT_MENU_RESET}${array[$k]} \n \r"
    fi
  done

  # Clear echo formatting
  echo -en "${_GUT_MENU_RESET}"
}

# Clears the menu
# @param {array} elements - Array of strings containing items to display
_gut_menu_clear() {
  # Get array
  declare -a array=("${!1}")

  # Iterate over array
  for k in "${!array[@]}"; do
    # Move cursor up
    echo -en "\033[1A"
  done
}
