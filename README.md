# gut

Collection of components that simplifies development workflow

## Components:
* [gut](#gut) - Core component
* [gut-color](#gut-color) - ANSI/VT100 color helpers
* [gut-git](#gut-git) - Git utilities
* [gut-kv](#gut-kv) - Key/Value store
* [gut-menu](#gut-menu) - Creates a selectable menu

## Dependencies:
* curl
* awk
* read
* echo
* base64
* git
* grep
* cat
* tr
* wc
* sed

## Install

```
$ curl -sSL https://github.com/jareddlc/gut/raw/master/install.sh | sh
```

This will create the env `$GUT_HOME` which defaults to `$HOME/.gut`

### gut
CLI for the Components

Usage: `gut -h`

### gut-color

ANSI/VT100 Color codes for scripts or terminal

Available colors:

| Color  | Foreground                                | Background                                |
| ------ | ----------------------------------------- | ----------------------------------------- |
| Black  | bash: `fblack`, PS1: `_GUT_PS1_F_BLACK`   | bash: `bblack`, PS1: `_GUT_PS1_B_BLACK`   |
| Red    | bash: `fred`, PS1: `_GUT_PS1_F_RED`       | bash: `bred`, PS1: `_GUT_PS1_B_`          |
| Green  | bash: `fgreen`, PS1: `_GUT_PS1_F_GREEN`   | bash: `bgreen`, PS1: `_GUT_PS1_B_`        |
| Yellow | bash: `fyellow`, PS1: `_GUT_PS1_F_YELLOW` | bash: `byellow`, PS1: `_GUT_PS1_B_YELLOW` |
| Blue   | bash: `fblue`, PS1: `_GUT_PS1_F_BLUE`     | bash: `bblue`, PS1: `_GUT_PS1_B_BLUE`     |
| Purple | bash: `fpurple`, PS1: `_GUT_PS1_F_PURPLE` | bash: `bpurple`, PS1: `_GUT_PS1_B_PURPLE` |
| Cyan   | bash: `fcyan`, PS1: `_GUT_PS1_F_CYAN`     | bash: `bcyan`, PS1: `_GUT_PS1_B_CYAN`     |
| White  | bash: `fwhite`, PS1: `_GUT_PS1_F_WHITE`   | bash: `bwhite`, PS1: `_GUT_PS1_B_WHITE`   |
| Default| PS1: `_GUT_PS1_F_DEFAULT`                 | PS1: `_GUT_PS1_B_DEFAULT`                 |
| Reset  | PS1: `_GUT_PS1_RESET`                     | PS1: `_GUT_PS1_RESET`                     |

### gut-git

Easier git workflows

```bash
# Save current PROMPT_COMMAND
if [[ ${PROMPT_COMMAND} != *"_gut_git_title_json"* ]]; then
  _PROMPT_COMMAND=$PROMPT_COMMAND
fi
# Runs after command is entered
PROMPT_COMMAND="_gut_git_title_json; $_PROMPT_COMMAND"
```

### gut-kv

Key/Value store


### gut-menu

Creates a menu and prompts user for selection


### Contributing
Want to contribute to the project? I've described the style guide for submiting pull requests.

#### Style guide

* Functions names are written in `snake_case` and must start with filename: `myfile_myfunction() {...}`
* Strings are enclosed with braces: `${my_string}`
* Variables are written in 'snake_case'
* Variable assignments via functions are called using subshells: `local encoded_key=$(echo "${key}" | base64)`
* Local variable names are written in lowercase
* Global variable names are written in uppercase

#### Docs

```
# Function summary
# @param {type} name - Description
function_name() {...}
```
