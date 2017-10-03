# gut

# source
source $HOME/gut-color.sh
source $HOME/gut-git.sh
source $HOME/gut-kv.sh
source $HOME/gut-menu.sh
source $HOME/gut-update.sh

_GUT_COMMANDS="color get set fetch log pull push reset update"

# Main - Take user input and call the corresponding components
# Args:
#   string - component to execute
gut() {
  if [ "$1" = "-h" ]; then
    _gut_help
  elif [ "$1" = "color" ]; then
    _gut_color_set
  elif [ "$1" = "get" ]; then
    _gut_get "${@:2}"
  elif [ "$1" = "set" ]; then
    _gut_set "${@:2}"
  elif [ "$1" = "fetch" ]; then
    _gut_fetch
  elif [ "$1" = "log" ]; then
    _gut_log
  elif [ "$1" = "pull" ]; then
    _gut_pull
  elif [ "$1" = "push" ]; then
    _gut_push
  elif [ "$1" = "reset" ]; then
    _gut_reset
  elif [ "$1" = "update" ]; then
    _gut_update
  else
    echo "[gut] Invalid command"
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

  COMPREPLY=( $(compgen -W "${_GUT_COMMANDS}" -- ${cur}) )

  return 0
}
complete -F _gut_completion gut
