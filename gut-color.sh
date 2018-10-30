#!/usr/bin/env bash

# Vars
GUT_DIR="${GUT_HOME:-$HOME/.gut}"
GUT_DB="gut.bdb"
GUT_COLOR_KEY="gut_color_key"

GUT_EXPORT_FUNCTIONS=("_gut_color_prompt")
GUT_EXPORT_NAMES=("color")
GUT_EXPORT_DESCRIPTIONS=("Sets the color of gut prompt")

_GUT_COLORS=("Black" "Red" "Green" "Yellow" "Blue" "Purple" "Cyan" "White")
_GUT_F_COLORS=("30" "31" "32" "33" "34" "35" "36" "37")
_GUT_B_COLORS=("40" "41" "42" "43" "44" "45" "46" "47")

# Foreground
_GUT_PS1_F_BLACK='\[\e[0;30m\]'
_GUT_PS1_F_RED='\[\e[0;31m\]'
_GUT_PS1_F_GREEN='\[\e[0;32m\]'
_GUT_PS1_F_YELLOW='\[\e[0;33m\]'
_GUT_PS1_F_BLUE='\[\e[0;34m\]'
_GUT_PS1_F_PURPLE='\[\e[0;35m\]'
_GUT_PS1_F_CYAN='\[\e[0;36m\]'
_GUT_PS1_F_WHITE='\[\e[0;37m\]'
_GUT_PS1_F_DEFAULT='\[\e[0;39m\]'

# Background
_GUT_PS1_B_BLACK='\[\e[0;40m\]'
_GUT_PS1_B_RED='\[\e[0;41m\]'
_GUT_PS1_B_GREEN='\[\e[0;42m\]'
_GUT_PS1_B_YELLOW='\[\e[0;43m\]'
_GUT_PS1_B_BLUE='\[\e[0;44m\]'
_GUT_PS1_B_PURPLE='\[\e[0;45m\]'
_GUT_PS1_B_CYAN='\[\e[0;46m\]'
_GUT_PS1_B_WHITE='\[\e[0;47m\]'
_GUT_PS1_B_DEFAULT='\[\e[0;49m\]'

# Reset
_GUT_PS1_RESET='\[\e[0m\]'

# Text attributes
# 0 - All attributes off
# 1 - Bold
# 4 - Underscore (on monochrome display adapter only)
# 5 - Blink on
# 7 - Reverse video on
# 8 - Concealed on

# \u - user
# \h - hostname short
# \w - directory

# Example: "\[\e[0;32;40m\]\h" Normal;Green foreground; Black background

# Retrieves the gut color key from ENV
_gut_color_get_env() {
  # get color from ENV if found
  if [[ ${GUT_COLOR_CODE} ]]; then
    echo "${GUT_COLOR_CODE}"
  else
    local color_code=$(_gut_color_get)

    export GUT_COLOR_CODE="${color_code}"
    echo "${color_code}"
  fi
}

# Retrieves guts color key
_gut_color_get() {
  local color=$(_gut_kv_get "${GUT_DIR}/${GUT_DB}" "${GUT_COLOR_KEY}")
  local found=""

  # Iterate over colors array
  for i in "${!_GUT_COLORS[@]}"; do
    if [ "${color}" = "${_GUT_COLORS[i]}" ]; then
      found="${_GUT_F_COLORS[i]}"
    fi
  done

  if [ "${found}" = "" ]; then
    # Set default color
    echo "31"
  else
    # Set found color
    echo "${found}"
  fi
}

# Stores guts color key
# @param {string} color_code - Color code
_gut_color_set() {
  local color_code=${1}
  local color="${_GUT_COLORS[color_code]}"

  # Store color code in ENV
  export GUT_COLOR_CODE="${_GUT_F_COLORS[color_code]}"
  _gut_kv_set "${GUT_DIR}/${GUT_DB}" "${GUT_COLOR_KEY}" "${color}"
}

# Prompts user to select gut color
_gut_color_prompt() {
  # Prompt user for color
  _gut_menu _GUT_COLORS[@]
  local indexColor=${?}

  _gut_color_set indexColor
}

# Outputs ANSI/VT100 color string
# @param {string} color - Color code
_gut_color() {
  local code=${1}
  local color_code=""

  # Check arguments
  if [ "${code}" = "" ]; then
    echo "[gut-color] No color provided"
    return 1;
  fi

  # Set color code
  case "${code}" in
    "fblack"  ) color_code="30";;
    "fred"    ) color_code="31";;
    "fgreen"  ) color_code="32";;
    "fyellow" ) color_code="33";;
    "fblue"   ) color_code="34";;
    "fpurple" ) color_code="35";;
    "fcyan"   ) color_code="36";;
    "fwhite"  ) color_code="37";;
    "bblack"  ) color_code="40";;
    "bred"    ) color_code="41";;
    "bgreen"  ) color_code="42";;
    "byellow" ) color_code="43";;
    "bblue"   ) color_code="44";;
    "bpurple" ) color_code="45";;
    "bcyan"   ) color_code="46";;
    "bwhite"  ) color_code="47";;
    "reset"   ) ;;
    *         ) echo "[gut-color] Invalid color"; return 1;;
  esac

  if [ "${code}" = "reset" ]; then
    echo -e "\033[0m"
  else
    echo -e "\033[0;${color_code}m"
  fi
}
