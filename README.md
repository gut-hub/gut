# gut

Collection of components that simplifies development workflow

### Components:
* gut - Core component
* [gut-color](#gut-color) - ANSI/VT100 color helpers
* [gut-git](#gut-git) - Git utilities
* [gut-kv](#gut-kv) - Key:Value store
* [gut-menu](#gut-menu) - Creates a selectable menu

### gut
Description: CLI for the Components

Example: `gut -h`

### gut-kv

##### Set
Description: Store a value by key

arguments:
* filePath - location of the file to store
* key - name of the key
* value - value to store

Example: `gut set "$HOME/gut.db" "hello" "world!"`

##### Get
Description: Retrieve value by key

arguments:
* filePath - location of the file to store
* key - name of the key
* value - value to store

Example: `gut get "$HOME/gut.db" "hello"`

### gut-color

Description: Set the color for gut text highlighting

Example: `gut color`

Available properties:
* `_GUT_PS1_F_BLACK` - Black foreground
* `_GUT_PS1_F_RED` - Red foreground
* `_GUT_PS1_F_GREEN` - Green foreground
* `_GUT_PS1_F_YELLOW` - Yellow foreground
* `_GUT_PS1_F_BLUE` - Blue foreground
* `_GUT_PS1_F_PURPLE` - Purple foreground
* `_GUT_PS1_F_CYAN` - Cyan foreground
* `_GUT_PS1_F_WHITE` - White foreground
* `_GUT_PS1_F_DEFAULT` - Default foreground
* `_GUT_PS1_B_BLACK` - Black background
* `_GUT_PS1_B_RED` - Red background
* `_GUT_PS1_B_GREEN` - Green background
* `_GUT_PS1_B_YELLOW` - Yellow background
* `_GUT_PS1_B_BLUE` - Blue background
* `_GUT_PS1_B_PURPLE` - Purple background
* `_GUT_PS1_B_CYAN` - Cyan background
* `_GUT_PS1_B_WHITE` - White background
* `_GUT_PS1_B_DEFAULT` - Default background
* `_GUT_PS1_RESET` - Resets color

### gut-menu

##### gut_menu
Description: Creates a menu and prompts user for selection

arguments:
* array - array of strings to display on the menu

Example: `_gut_menu git_remote_name_url_list[@]`


### gut-git

##### gut_log
Description: Condensed version of `git log`

##### gut_fetch
Description: Prompts user for a remote repo to `git fetch`

##### gut_pull
Description: Prompts user for a git remote repo and branch to `git pull`

##### gut_push
Description: Prompts user for a git remote repo and `git push` current branch

##### gut_reset
Description: Prompts user for git hash to `git reset --soft`

##### More

* `_gut_title_json` - Sets the terminal's title with git info
* `_gut_status_short` - Prints a short summary of `git status` using single characters
* ...look at the source for more git utilities

```bash
# Save current PROMPT_COMMAND
if [[ ${PROMPT_COMMAND} != *"_gut_title_json"* ]]; then
  _PROMPT_COMMAND=$PROMPT_COMMAND
fi
# Runs after command is entered
PROMPT_COMMAND="_gut_title_json; $_PROMPT_COMMAND"
```
