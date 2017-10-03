# gut-update

# Globals
GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

# Update - Function to update local gut version
_gut_update() {
  _gut_update_download "gut-color.sh"
  _gut_update_download "gut-git.sh"
  _gut_update_download "gut-kv.sh"
  _gut_update_download "gut-menu.sh"
  _gut_update_download "gut-update.sh"
  _gut_update_download "gut.sh"
  echo -e "${GRE}Download complete${DEF}"
}

# Download - Pulls a file directly from GitHub
_gut_update_download () {
  echo -e "${GRE}Downloading: ${YEL}$1${DEF}"
  curl -sSL "https://github.com/jareddlc/gut/raw/master/$1" -o $HOME/$1
}
