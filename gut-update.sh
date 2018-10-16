#!/usr/bin/env bash

# Colors
GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

# Vars
GUT_DIR="${GUT_HOME:-$HOME/.gut}"

# Updates gut
_gut_update() {
  _gut_update_download "gut-color.sh"
  _gut_update_download "gut-git.sh"
  _gut_update_download "gut-kv.sh"
  _gut_update_download "gut-menu.sh"
  _gut_update_download "gut-update.sh"
  _gut_update_download "gut.sh"
  echo -e "${GRE}Download complete${DEF}"
}

# Downloads a file from gut GitHub repo
# @param {string} filename - Name of file from gut git repo
_gut_update_download() {
  echo -e "${GRE}Downloading: ${YEL}${1}${DEF}"
  curl -sSL "https://github.com/jareddlc/gut/raw/master/${1}" -o ${GUT_DIR}/${1}
}
