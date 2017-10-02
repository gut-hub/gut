# gut-update

GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

download () {
  local file=$1
  echo -e "${GRE}Downloading: ${YEL}${file}${DEF}"
  curl -sSL "https://github.com/jareddlc/gut/raw/master/${file}" -o $HOME/${file}
}

download "gut-color.sh"
download "gut-git.sh"
download "gut-kv.sh"
download "gut-menu.sh"
download "gut-update.sh"
download "gut.sh"

echo -e "${GRE}Download complete${DEF}"
