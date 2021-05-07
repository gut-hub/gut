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
GUT_FILE="gut"

# Create gut directory
if [ ! -d "${GUT_DIR}" ]; then
  echo -e "${YEL}Creating directory: ${GUT_DIR}${DEF}"
  mkdir "${GUT_DIR}"
fi

echo -e "${YEL}Getting latest release${DEF}"
curl -s -u "username":"" https://api.github.com >/dev/null

# Get latest release
release=$(curl -s https://api.github.com/repos/jareddlc/gut/releases/latest)
version=$(echo "${release}" | grep "tag_name" | awk '{ print $2 }')
url=$(echo "${release}" | grep "browser_download_url" | awk '{ print $2 }')

# Clean strings
url="${url%?}"
url="${url%\"}"
url="${url#\"}"

# Download
echo -e "${YEL}Downloading: ${GRE}${url}${DEF}"
curl -sSL "${url}" -o "${GUT_FILE}"

# Move to gut directory
mv "${GUT_FILE}" "${GUT_DIR}"
chmod +x "${GUT_DIR}/${GUT_FILE}"
echo -e "${YEL}Download complete: ${GRE}${GUT_DIR}/${GUT_FILE}${DEF}"

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
