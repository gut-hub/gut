#!/usr/bin/env bash

# Colors
RED="\033[0;31m"
GRE="\033[0;32m"
YEL="\033[0;33m"
BLU="\033[0;34m"
DEF="\033[0;39m"
RES="\033[0m"

# GUT
GUT_DIR="${HOME}/.gut"

# Shells
BASH_PROFILE="${HOME}/.bash_profile"
BASH_RC="${HOME}/.bashrc"
ZSH_PROFILE="${HOME}/.zprofile"
ZSH_RC="${HOME}/.zshrc"

BASH_PATH="export PATH=$PATH:$HOME/.gut"
ZSH_PATH="path+=('$HOME/.gut')"

# OS and Arch
arch=$(uname -m)
GUT_FILE="gut-linux"
if [[ "$OSTYPE" == "darwin"* ]]; then
  GUT_FILE="gut-macos-x86"
  if [[  "$arch" == "arm64"* ]]; then
    GUT_FILE="gut-macos-aarch64"
  fi
fi

# Create gut directory
if [ ! -d "${GUT_DIR}" ]; then
  echo -e "${YEL}Creating directory: ${GUT_DIR}${DEF}"
  mkdir "${GUT_DIR}"
fi

# Get latest release
echo -e "${YEL}Getting latest release${DEF}"
release=$(curl -s https://api.github.com/repos/gut-hub/gut/releases/latest)
version=$(echo "${release}" | grep "tag_name" | awk '{ print $2 }')
url=$(echo "${release}" | grep "browser_download_url" | awk '{ print $2 }')
url=$(echo "${url}" | grep ${GUT_FILE})

# Clean strings
url="${url%?}"
url="${url%\"}"
url="${url#\"}"

# Download
echo -e "${YEL}Downloading: ${GRE}${url}${DEF}"
curl -sSL "${url}" -o "${GUT_DIR}/gut"
chmod +x "${GUT_DIR}/gut"
echo -e "${YEL}Download complete: ${GRE}${GUT_DIR}/gut${DEF}"

install_bash() {
  local dest=${1}
  found=$(grep "${BASH_PATH}" "${dest}")
  if [ ! "${found}" ]; then
    echo -e "${YEL}Adding gut to PATH: ${GRE}${dest}${DEF}"
    echo "${BASH_PATH}" >> "${dest}"
    echo -e "${YEL}Please open a new terminal or source profile to use gut:${DEF}"
    echo -e "${BLU}    $ source ${dest}${DEF}"
  else
    echo -e "${YEL}Gut already present in PATH: ${GRE}${dest}${DEF}"
  fi
}

install_zsh() {
  local dest=${1}
  found=$(grep "${ZSH_PATH}" "${dest}")
  if [ ! "${found}" ]; then
    echo -e "${YEL}Adding gut to PATH: ${GRE}${dest}${DEF}"
    echo "${ZSH_PATH}" >> "${dest}"
    echo "export PATH" >> "${dest}"
    echo -e "${YEL}Please open a new terminal or source profile to use gut:${DEF}"
    echo -e "${BLU}    $ source ${dest}${DEF}"
  else
    echo -e "${YEL}gut already present in PATH: ${GRE}${dest}${DEF}"
  fi
}

# Add gut to shell profile
if [ -e "${ZSH_PROFILE}" ]; then
  install_zsh "${ZSH_PROFILE}"
elif [ -e "${ZSH_RC}" ]; then
  install_zsh "${ZSH_RC}"
elif [ -e "${BASH_PROFILE}" ]; then
 install_bash "${BASH_PROFILE}"
elif [ -e "${BASH_RC}" ]; then
 install_bash "${BASH_RC}"
else
  echo -e "${YEL}gut was not added to a shell profile.${DEF}"
  echo -e "${YEL}To use gut, Please add gut directory to the PATH:${DEF}"
  echo -e "${BLU}${GUT_DIR}{DEF}"
fi
