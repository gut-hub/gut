#!/usr/bin/env bash

# Colors
GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

# Copies a file to gut home
# @param {string} filename - Location of file
copy_file() {
  cp "${1}" ${2}/${1}
}

# Get version
version=$(cat gut.sh | grep "GUT_VER=" | awk -F "=" '{ print $2 }')
version="${version%\"}"
version="${version#\"}"

dir="gut-v${version}"

# Create temp dir
mkdir "${dir}"

copy_file "gut-cert.sh" "${dir}"
copy_file "gut-color.sh" "${dir}"
copy_file "gut-column.sh" "${dir}"
copy_file "gut-env.sh" "${dir}"
copy_file "gut-git.sh" "${dir}"
copy_file "gut-kv.sh" "${dir}"
copy_file "gut-menu.sh" "${dir}"
copy_file "gut-time.sh" "${dir}"
copy_file "gut-update.sh" "${dir}"
copy_file "gut.sh" "${dir}"

# Compress directory
tar -czf ${dir}.tar.gz "${dir}"
echo -e "${GRE}Created: ${YEL}${dir}.tar.gz${DEF}"

# Remove temp dir
rm -rf ${dir}
