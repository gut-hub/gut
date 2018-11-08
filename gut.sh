#!/usr/bin/env bash

# Vars
GUT_DIR="${GUT_HOME:-$HOME/.gut}"
GUT_VER="0.1.0"

GUT_ENV_FUNCTIONS="GUT_FUNCS"
GUT_ENV_NAMES="GUT_NAMES"
GUT_ENV_DESCRIPTIONS="GUT_DESCS"

# Main
# @param {string} command - Command to execute
gut() {
  # Get plugins from ENV
  if [[ -n ${!GUT_ENV_FUNCTIONS} ]]; then
    # No-op
    echo -n ""
  else
    # Get plugins
    _gut_load_plugins
  fi

  # Backup IFS
  savedIFS=$IFS
  IFS=':'

  funcs=($(echo "${!GUT_ENV_FUNCTIONS}"))
  names=($(echo "${!GUT_ENV_NAMES}"))
  descs=($(echo "${!GUT_ENV_DESCRIPTIONS}"))

  # Restore IFS
  IFS=$savedIFS

  # Iterate over array
  for i in "${!names[@]}"; do
    # Check for whitespace
    if [ ${#names[$i]} -ge 2 ]; then
      if [ "${1}" = "${names[$i]}" ]; then
          # Call functions
          ${funcs[$i]} "${@:2}"
          return 0
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
  # get plugins from ENV
  if [[ -n ${!GUT_ENV_FUNCTIONS} ]]; then
    # No-op
    echo -n ""
  else
    # Get plugins
    _gut_load_plugins
  fi

  # Backup IFS
  savedIFS=$IFS
  IFS=':'

  funcs=($(echo "${!GUT_ENV_FUNCTIONS}"))
  names=($(echo "${!GUT_ENV_NAMES}"))
  descs=($(echo "${!GUT_ENV_DESCRIPTIONS}"))

  # Restore IFS
  IFS=$savedIFS

  # Displays plugins
  echo "usage: gut [command]"
  echo ""
  echo "commands:"
  echo ""

  # Iterate over array
  for i in "${!names[@]}"; do
    # Check for whitespace
    if [ ${#names[$i]} -ge 2 ]; then
      _gut_column_echo "${names[$i]}" "${descs[$i]}" "20"
    fi
  done

  echo ""
}

# Displays the version of gut
_gut_version() {
  echo "v${GUT_VER}"
}

# Load plugins in ${GUT_DIR}
_gut_load_plugins() {
  local exclude=(" " "." ".." "gut.sh" "gut.bdb" "install.sh" "README.md")
  # Get file names
  local list=($(ls -al ${GUT_DIR} | awk '{ print $9 }'))
  declare -a files=()

  # Iterate over files in GUT_DIR
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

  local gut_functions=""
  local gut_names=""
  local gut_descriptions=""

  # Iterate over valid files
  for i in "${!files[@]}"; do
    # Source the files
    source "${GUT_DIR}/${files[$i]}"

    # Get plugin functions, names, and descriptions
    local funcs=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_FUNCTIONS")
    local names=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_NAMES")
    local descs=$(cat "${GUT_DIR}/${files[$i]}" | grep "GUT_EXPORT_DESCRIPTIONS")

    # Functions
    if [[ -n ${funcs} ]]; then
      local f=$(echo "${funcs}" | awk -F "[()]" '{print $2}')

      # Backup IFS
      savedIFS=$IFS
      IFS='"'

      # Create array
      a_functions=($(echo "${f}"))

      # Iterate over array
      for i in "${!a_functions[@]}"; do
        # Check for null strings
        if [[ -n ${a_functions[$i]} ]]; then
          # Check for whitespace
          if [ ${#a_functions[$i]} -ge 2 ]; then
            gut_functions="${gut_functions}:${a_functions[$i]}"
          fi
        fi
      done

      # Restore IFS
      IFS=$savedIFS
    fi

    # Names
    if [[ -n ${names} ]]; then
      local n=$(echo ${names} | awk -F "[()]" '{print $2}')

      # Backup IFS
      savedIFS=$IFS
      IFS='"'

      # Create array
      a_names=($(echo "${n}"))

      # Iterate over array
      for i in "${!a_names[@]}"; do
        # Check for null strings
        if [[ -n ${a_names[$i]} ]]; then
          # Check for whitespace
          if [ ${#a_names[$i]} -ge 2 ]; then
            gut_names="${gut_names}:${a_names[$i]}"
          fi
        fi
      done

      # Restore IFS
      IFS=$savedIFS
    fi

    # Descriptions
    if [[ -n ${descs} ]]; then
      local d=$(echo ${descs} | awk -F "[()]" '{print $2}')

      # Backup IFS
      savedIFS=$IFS
      IFS='"'

      # Create array
      a_descriptions=($(echo "${d}"))

      # Iterate over array
      for i in "${!a_descriptions[@]}"; do
        # Check for null strings
        if [[ -n ${a_descriptions[$i]} ]]; then
          # Check for whitespace
          if [ ${#a_descriptions[$i]} -ge 2 ]; then
            gut_descriptions="${gut_descriptions}:${a_descriptions[$i]}"
          fi
        fi
      done

      # Restore IFS
      IFS=$savedIFS
    fi
  done

  # Add version
  gut_functions="${gut_functions}:_gut_version"
  gut_names="${gut_names}:version"
  gut_descriptions="${gut_descriptions}:Displays the version of gut"

  # Save to env
  _gut_env_set "${GUT_ENV_FUNCTIONS}" "${gut_functions}"
  _gut_env_set "${GUT_ENV_NAMES}" "${gut_names}"
  _gut_env_set "${GUT_ENV_DESCRIPTIONS}" "${gut_descriptions}"
}

# Completion - Tab completion
_gut_completion() {
  # Get plugins from ENV
  if [[ -n ${!GUT_ENV_FUNCTIONS} ]]; then
    # No-op
    echo -n ""
  else
    # Get plugins
    _gut_load_plugins
  fi

  # Backup IFS
  savedIFS=$IFS
  IFS=':'

  funcs=($(echo "${!GUT_ENV_FUNCTIONS}"))
  names=($(echo "${!GUT_ENV_NAMES}"))
  descs=($(echo "${!GUT_ENV_DESCRIPTIONS}"))

  # Restore IFS
  IFS=$savedIFS

  local gut_completion=""

  for i in "${!names[@]}"; do
    # Check for whitespace
    if [ ${#names[$i]} -ge 2 ]; then
      if [ ${i} -eq 1 ]; then
        gut_completion="${names[$i]}"
      else
        gut_completion="${gut_completion} ${names[$i]}"
      fi
    fi
  done

  local cur prev

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  COMPREPLY=( $(compgen -W "${gut_completion}" -- ${cur}) )

  return 0
}
complete -F _gut_completion gut

# Load gut
_gut_load_plugins
