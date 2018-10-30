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

_GUT_COMMANDS_COMPLETION="color get set fetch log pull push reset update version"

GUT_FUNCTIONS=()
GUT_NAMES=()
GUT_DESCRIPTIONS=()

# Main
# @param {string} command - Command to execute
gut() {
  # get plugins
  _gut_plugins

  # backup IFS
  savedIFS=$IFS
  IFS='"'

  # recreate array
  funcs=($( echo "${GUT_FUNCTIONS[*]}"))
  names=($( echo "${GUT_NAMES[*]}"))
  descs=($( echo "${GUT_DESCRIPTIONS[*]}"))

  # restore IFS
  IFS=$savedIFS

  # Iterate over names array
  for i in "${!names[@]}"; do
    # check for null strings
    if [[ -n ${names[$i]} ]]; then
      # check for whitespace
      if [ ${#names[$i]} -ge 2 ]; then
        if [ "${1}" = "${names[$i]}" ]; then
          # call functions
          ${funcs[$i]} "${@:2}"
          return 0
        fi
      fi
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
  # get plugins
  _gut_plugins

  # backup IFS
  savedIFS=$IFS
  IFS='"'

  # recreate array
  funcs=($( echo "${GUT_FUNCTIONS[*]}"))
  names=($( echo "${GUT_NAMES[*]}"))
  descs=($( echo "${GUT_DESCRIPTIONS[*]}"))

  # restore IFS
  IFS=$savedIFS

  # displays plugins
  echo "usage: gut [command]"
  echo ""
  echo "commands:"
  echo ""

  # Iterate over function names array
  for i in "${!names[@]}"; do
    # check for null strings
    if [[ -n ${names[$i]} ]]; then
      # check for whitespace
      if [ ${#names[$i]} -ge 2 ]; then
        _gut_column_echo "${names[$i]}" "${descs[$i]}" "20"
      fi
    fi
  done

  echo ""
}

# Displays the version of gut
_gut_version() {
  echo "v${GUT_VER}"
}

# Get a list of plugins
_gut_plugins() {
  local exclude=(" " "." ".." "gut.sh" "gut.bdb" "install.sh" "README.md")
  # Get file names
  local list=($(ls -al ${GUT_DIR} | awk '{ print $9 }'))
  declare -a files=()

  # iterate over files in GUT_DIR
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

  declare -a gut_functions=()
  declare -a gut_names=()
  declare -a gut_descriptions=()

  # iterate over valid files
  for i in "${!files[@]}"; do
    # Source the files
    source "${GUT_DIR}/${files[$i]}"

    # Get plugin functions, names, and descriptions
    local funcs=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_FUNCTIONS")
    local names=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_NAMES")
    local descs=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_DESCRIPTIONS")

    if [[ -n ${funcs} ]]; then
      local f=$(echo "${funcs}" | awk -F "[()]" '{print $2}')
      gut_functions+=("${f}")
    fi

    if [[ -n ${names} ]]; then
      local n=$(echo ${names} | awk -F "[()]" '{print $2}')
      gut_names+=("${n}")
    fi

    if [[ -n ${descs} ]]; then
      local d=$(echo ${descs} | awk -F "[()]" '{print $2}')
      gut_descriptions+=("${d}")
    fi
  done

  # add version
  gut_functions+=("_gut_version")
  gut_names+=("version")
  gut_descriptions+=("Displays the version of gut")

  # override global vars
  GUT_FUNCTIONS=("${gut_functions[@]}")
  GUT_NAMES=("${gut_names[@]}")
  GUT_DESCRIPTIONS=("${gut_descriptions[@]}")
}

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
