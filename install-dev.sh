# gut-dev

# Globals
GRE="\033[0;32m"
YEL="\033[0;33m"
DEF="\033[0;39m"

BASH_PROFILE="$HOME/.bash_profile"
BASH_RC="$HOME/.bashrc"
GUT_DIR="${GUT_HOME:-$HOME/.gut}"
GUT_SH='$GUT_HOME/gut.sh'

echo "$GUT_DIR"
if [ ! -d "$GUT_DIR" ]; then
  echo -e "${BLU}Creating directory: ${GUT_DIR}${DEF}"
  mkdir "${GUT_DIR}"
fi

install() {
  local dest=$1
  found=$(grep "$GUT_SH" "$dest")
  if [ ! "$found" ]; then
    echo ""
    echo -e "${BLU}Installing gut in: ${YEL}$dest${DEF}"
    echo "export GUT_HOME=$GUT_DIR" >> "$dest"
    echo "source $GUT_SH" >> "$dest"

    echo -e "${GRE}Please open a new terminal or re-source the ${DEF}${YEL}${dest} ${DEF}${GRE}with the command below:${DEF}"
    echo ""
    echo -e "    $ source $dest"
    echo ""
  fi
  echo -e "${BLU}Install complete${DEF}"
}

copy_file() {
  echo -e "${GRE}Copying: ${YEL}$1${DEF}"
  cp "$1" $GUT_DIR/$1
}

copy_file "gut-color.sh"
copy_file "gut-git.sh"
copy_file "gut-kv.sh"
copy_file "gut-menu.sh"
copy_file "gut-update.sh"
copy_file "gut.sh"
echo -e "${GRE}Copy complete${DEF}"

if [ -e "$BASH_PROFILE" ]; then
  install "$BASH_PROFILE"
elif [ -e "$BASH_RC" ]; then
  install "$BASH_RC"
else
  echo -e "${BLU}Did not find a .bashrc or .bash_profile${DEF}"
  echo -e "${YEL}To use gut, source with the command below:${RES}"
  echo -e "source $GUT_SH"
fi
