#!/usr/bin/env bash

# Vars
GUT_DIR="${GUT_HOME:-$HOME/.gut}"
GUT_VER="0.1.0"

# Source
source ${GUT_DIR}/gut-color.sh
source ${GUT_DIR}/gut-column.sh
source ${GUT_DIR}/gut-git.sh
source ${GUT_DIR}/gut-kv.sh
source ${GUT_DIR}/gut-menu.sh
source ${GUT_DIR}/gut-update.sh

_GUT_COMMANDS=("color" "get" "set" "fetch" "log" "pull" "push" "reset" "update" "version")
_GUT_COMMANDS_COMPLETION="color get set fetch log pull push reset update version"
_GUT_COMMANDS_FUNCTIONS=("_gut_color_prompt" "_gut_kv_get" "_gut_kv_set" "_gut_git_fetch" "_gut_git_log_colored" "_gut_git_pull" "_gut_git_push" "_gut_git_reset" "_gut_update" "_gut_version")

# Main
# @param {string} command - Command to execute
gut() {
  # Iterate over commands array
  for i in "${!_GUT_COMMANDS[@]}"; do
    if [ "${1}" = "${_GUT_COMMANDS[$i]}" ]; then
      ${_GUT_COMMANDS_FUNCTIONS[$i]} "${@:2}"
      return 0
    fi
  done

  if [ "$1" == "-h" ]; then
    _gut_help
  elif [ "$1" == "-v" ]; then
    _gut_version
  else
    echo "[gut] invalid command. see help for usage: $ gut -h"
  fi
}

# Displays help menu
_gut_help() {
  echo "usage: gut [command]"
  echo ""
  echo "commands:"
  echo ""
  echo "color         Set the color for gut text highlighting"
  echo ""
  echo "get           Get key"
  echo "set           Set key"
  echo ""
  echo "fetch         Performs a git fetch on the selected remote repo"
  echo "log           Performs a git log"
  echo "pull          Performs a git pull on the selected remote branch"
  echo "push          Performs a git push on the selected remote branch"
  echo "reset         Performs a git reset --soft to the selected git hash"
  echo "update        Performs an update to retrieve the latest version of gut"
  echo "version       Shows the version of gut"
  echo ""
}

# Displays version of gut
_gut_version() {
  echo "v${GUT_VER}"
}

# Get a list of plugins
_gut_plugins() {
  local exclude=(" " "." ".." "gut.sh" "gut.bdb" "install.sh" "README.md")
  # Get file names
  local list=($(ls -al ${GUT_DIR} | awk '{ print $9 }'))
  declare -a files=()

  for i in "${!list[@]}"; do
    # Don't add if the filename is in the exclude list
    let add=0;
    for j in "${!exclude[@]}"; do
      if [ "${list[$i]}" == "${exclude[$j]}" ]; then
        (( add = 1 ))
        break
      fi
    done

    # Add the filename
    if [ "$add" -lt "1" ]; then
      files+=("${list[$i]}")
    fi
  done

  declare -a functions=()
  declare -a names=()

  for i in "${!files[@]}"; do
    # Source the files
    source "${GUT_DIR}/${files[$i]}"

    # Get plugin functions and names
    local f=$(cat "${GUT_DIR}/${files[$i]}" | grep "_GUT_EXPORT_FUNCTIONS")
    local n=$(cat "${GUT_DIR}/${files[$i]}" | grep "_GUT_EXPORT_NAMES")

    # eval $f
    # echo "$_GUT_EXPORT_FUNCTIONS"

  done
}

# Run plugins (Disabled until completed)
# _gut_plugins

# Completion - Tab completion
_gut_completion() {
  local cur prev

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  COMPREPLY=( $(compgen -W "${_GUT_COMMANDS_COMPLETION}" -- ${cur}) )

  return 0
}
complete -F _gut_completion gut
