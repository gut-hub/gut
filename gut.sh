# gut
GUT_DIR="${GUT_HOME:-$HOME/.gut}"

# source
source $GUT_DIR/gut-color.sh
source $GUT_DIR/gut-git.sh
source $GUT_DIR/gut-kv.sh
source $GUT_DIR/gut-menu.sh
source $GUT_DIR/gut-update.sh

_GUT_COMMANDS=("color" "get" "set" "fetch" "log" "pull" "push" "reset" "update")
_GUT_COMMANDS_COMPLETION="color get set fetch log pull push reset update"
_GUT_COMMANDS_FUNCTIONS=("_gut_color_set" "_gut_get" "_gut_set" "_gut_fetch" "_gut_log" "_gut_pull" "_gut_push" "_gut_reset" "_gut_update")

# Main - Take user input and call the corresponding components
# Args:
#   string - component to execute
gut() {
  # Iterate over commands array
  for i in "${!_GUT_COMMANDS[@]}"; do
    if [ "$1" = "${_GUT_COMMANDS[$i]}" ]; then
      ${_GUT_COMMANDS_FUNCTIONS[$i]} "${@:2}"
      return 0
    fi
  done

  if [ "$1" != "-h" ]; then
    echo "[gut] invalid command. see help for usage: $ gut -h"
  else
    _gut_help
  fi
}

# Help - Displays help
_gut_help() {
  echo "usage: gut [command]"
  echo ""
  echo "commands:"
  echo ""
  echo "color         Set the color for gut text highlighting"
  echo ""
  echo "get           Get key"
  echo "set           Set key"
  echo ""
  echo "fetch         Performs a git fetch on the selected remote repo"
  echo "log           Performs a git log"
  echo "pull          Performs a git pull on the selected remote branch"
  echo "push          Performs a git push on the selected remote branch"
  echo "reset         Performs a git reset --soft to the selected git hash"
  echo "update        Performs an update to retrieve the latest version of gut"
  echo ""
}

# Completion - Add tab completion
_gut_completion() {
  local cur prev

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  COMPREPLY=( $(compgen -W "${_GUT_COMMANDS_COMPLETION}" -- ${cur}) )

  return 0
}
complete -F _gut_completion gut
