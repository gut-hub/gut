#!/usr/bin/env bash

# Colors
GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

# Vars
GUT_DIR="${GUT_HOME:-$HOME/.gut}"

GUT_EXPORT_FUNCTIONS=("_gut_update")
GUT_EXPORT_NAMES=("update")
GUT_EXPORT_DESCRIPTIONS=("Updates gut")

# Updates gut
_gut_update() {
  echo -e "${YEL}Getting latest release${DEF}"
  curl -s -u "username":"" https://api.github.com >/dev/null

  # Get latest release
  local release=$(curl -s https://api.github.com/repos/jareddlc/gut/releases/latest)
  local version=$(echo "${release}" | grep "tag_name" | awk '{ print $2 }')
  local url=$(echo "${release}" | grep "browser_download_url" | awk '{ print $2 }')

  # Clean strings
  version="${version%?}"
  version="${version%\"}"
  version="${version#\"}"
  url="${url%?}"
  url="${url%\"}"
  url="${url#\"}"
  file="gut-${version}.tar.gz"
  dir="gut-${version}"

  # Download
  echo -e "${YEL}Downloading: ${GRE}${version} - ${url}${DEF}"
  curl -sSL "${url}" -o "${file}"

  # Untar
  tar -C ${PWD} -xvf "${file}"

  # Move
  cp -R "${dir}/." "${GUT_DIR}"/

  # Clean up
  rm -rf "${dir}"
  rm "${file}"

  echo -e "${GRE}Download complete${DEF}"
}

# Downloads a file from gut GitHub repo
# @param {string} filename - Name of file from gut git repo
_gut_update_download() {
  echo -e "${GRE}Downloading: ${YEL}${1}${DEF}"
  curl -sSL "https://github.com/jareddlc/gut/raw/master/${1}" -o ${GUT_DIR}/${1}
}
