#!/usr/bin/env bash

# Colors
GRE="\033[0;32m"
YEL="\033[0;33m"
BLU="\033[0;34m"
DEF="\033[0;39m"
RES="\033[0m"

# Vars
BASH_PROFILE="${HOME}/.bash_profile"
BASH_RC="${HOME}/.bashrc"
GUT_DIR="${HOME}/.gut"
GUT_PATH='export PATH=$PATH:$HOME/.gut'
GUT_FILE="gut-linux"
if [[ "$OSTYPE" == "darwin"* ]]; then
  GUT_FILE="gut-macos"
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

insert_source() {
  local dest=${1}
  found=$(grep "${GUT_PATH}" "${dest}")
  if [ ! "${found}" ]; then
    echo -e "${YEL}Adding PATH in: ${GRE}${dest}${DEF}"
    echo "${GUT_PATH}" >> "${dest}"
  fi
  echo -e "${YEL}Please open a new terminal or resource to use gut:${DEF}"
  echo -e "${BLU}    $ source ${dest}${DEF}"
}

# Add source information to .bash_profile or .bashrc
if [ -e "${BASH_PROFILE}" ]; then
  insert_source "${BASH_PROFILE}"
elif [ -e "${BASH_RC}" ]; then
  insert_source "${BASH_RC}"
else
  echo -e "${YEL}Did not find a .bash_profile or .bashrc${DEF}"
  echo -e "${YEL}To use gut, Please add gut directory to the PATH:${RES}"
  echo -e "${BLU}source ${GUT_EXEC}"
fi
