# install

GRE="\033[0;32m"
YEL="\033[0;33m"
BLU="\033[0;34m"
DEF="\033[0;39m"
RES="\033[0m"

echo -e "${BLU}Installing gut${DEF}"
echo -e "${GRE}Downloading: ${YEL}gut-color.sh${DEF}"

$(curl -L https://github.com/jareddlc/gut/raw/master/gut-color.sh 2>/dev/null > $HOME/gut-color.sh)

echo -e "${GRE}Downloading: ${YEL}gut-git.sh${DEF}"
$(curl -L https://github.com/jareddlc/gut/raw/master/gut-git.sh 2>/dev/null > $HOME/gut-git.sh)

echo -e "${GRE}Downloading: ${YEL}gut-kv.sh${DEF}"
$(curl -L https://github.com/jareddlc/gut/raw/master/gut-color.sh 2>/dev/null > $HOME/gut-kv.sh)

echo -e "${GRE}Downloading: ${YEL}gut.sh${DEF}"
$(curl -L https://github.com/jareddlc/gut/raw/master/gut.sh 2>/dev/null > $HOME/gut.sh)

echo -e "${GRE}Download complete${DEF}"

bash_profile="$HOME/.bash_profile"
bash_gut='$HOME/gut.sh'
echo -e "${BLU}Checking: ${YEL}$bash_profile${DEF}"
if [ -e "$HOME/.bash_profile" ]; then
  found=$(grep "$bash_gut" "$bash_profile")
  if [ "$found" ]; then
    echo -e "${YEL}gut already sourced${RES}"
  else
    echo -e "${GRE}Sourcing gut in: ${YEL}$bash_profile${DEF}"
    echo "source $bash_gut" >> "$HOME/.bash_profile"
    echo -e ""
    echo -e "${BLU}Install complete${DEF}"
    echo -e "${GRE}Please open a new terminal or re-source the ${DEF}${YEL}.bash_profile ${DEF}${GRE}with the command below:${DEF}"
    echo ""
    echo '"source $HOME/.bash_profile"'
  fi
fi
