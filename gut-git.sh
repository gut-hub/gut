# gut-git

# Log - Performs a git log
_gut_log() {
  # Git format placeholders
  # %h: abbreviated commit hash
  # %s: subject
  # %cd: committer date
  # %an: author name
  git log -n 25 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# Fetch - Performs a git fetch on the selected remote repo
_gut_fetch() {
  # Save IFS
  local SAVEIFS=$IFS
  # Change IFS to new line.
  IFS=$'\n'

  # Get git remotes
  local git_remote_name_list=($(_gut_remote_name_list))
  local git_remote_name_url_list=($(_gut_remote_name_url_list))
  # git fetch <remote> -v 2>&1 | grep "=" | awk '{ print $5; }' or awk '{ print $7; }' for name/branch

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url_list[@]
  local index_remote=$?

  # Run git command
  git fetch "${git_remote_name_list[$index_remote]}"

  # Restore IFS
  IFS=$SAVEIFS
}

# Pull - Performs a git pull on the selected remote branch
_gut_pull() {
  # Save IFS
  local SAVEIFS=$IFS
  # Change IFS to new line.
  IFS=$'\n'

  # Get git remotes
  local git_remote_name_list=($(_gut_remote_name_list))
  local git_remote_name_url_list=($(_gut_remote_name_url_list))

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url_list[@]
  local index_remote=$?

  # Get remote branch list
  local git_branch_remote_full_list=($(_gut_branch_remote_full_list ${git_remote_name_list[$index_remote]}))
  local git_branch_remote_list=($(_gut_branch_remote_list ${git_remote_name_list[$index_remote]}))

  # Select branch
  echo "Select a branch:"
  _gut_menu git_branch_remote_full_list[@]
  local index_branch=$?

  # Run git command
  git pull "${git_remote_name_list[$index_remote]}" "${git_branch_remote_list[$index_branch]}"

  # Restore IFS
  IFS=$SAVEIFS
}

# Push - Performs a git push on the selected remote branch
_gut_push() {
  # Save IFS
  local SAVEIFS=$IFS
  # Change IFS to new line.
  IFS=$'\n'

  # Get git remotes
  local git_remote_name_list=($(_gut_remote_name_list))
  local git_remote_name_url_list=($(_gut_remote_name_url_list))

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url_list[@]
  local index_remote=$?

  # Get current git branch
  local git_branch_current=$(_gut_branch_current)

  # Run git command
  git push "${git_remote_name_list[$index_remote]}" "$git_branch_current"
  local exitPush=$?

  if [ "$exitPush" != "0" ]; then
    echo "Push failed, force push?"

    local _force=(No Yes)

    _gut_menu _force[@]
    local index_force=$?

    if [ "$index_force" = "1" ]; then
      git push "${git_remote_name_list[$index_remote]}" "$git_branch_current" --force
    fi
  fi

  # Restore IFS
  IFS=$SAVEIFS
}

# Reset - Performs a git reset --soft on the selected git hash
_gut_reset() {
  # Save IFS
  local SAVEIFS=$IFS
  # Change IFS to new line.
  IFS=$'\n'

  # Get git commits
  local git_log_list=($(_gut_log_list))
  local git_log_hash_list=($(_gut_log_hash_list))

  # Select commit
  echo "Select a commit:"
  _gut_menu git_log_list[@]
  local index_commit=$?

  # Run git command
  git reset --soft ${git_log_hash_list[$index_commit]}
}

# Branch remote list - Prints the git branch list of a remote branch
_gut_branch_remote_list() {
  # Fail if no branch names are provided
  if [ -z "$1" ]; then
    echo "invalid parameter passed: _gut_branch_remote_list"
    return -1
  fi

  local git_braches_remote_list=$(git branch -a | grep "$1" | tr -d "* " | awk -F / '{ print $3; }')
  echo "$git_braches_remote_list"
}

# Branch remote full list - Prints the git branch list of a remote branch full description
_gut_branch_remote_full_list() {
  # Fail if no branch names are provided
  if [ -z "$1" ]; then
    echo "invalid parameter passed: _gut_branch_remote_full_list"
    return -1
  fi

  local git_braches_remote_full_list=$(git branch -a | grep "$1" | tr -d "* ") # | awk -F / '{ print $3; }'
  echo "$git_braches_remote_full_list"
}

# Branch list - Prints the git branch list
_gut_branch_list() {
  local git_branch_list=$(git branch | awk '{ $1=$1; print }' | tr -d "* ")
  echo "$git_branch_list"
}

# Branch current - Prints the current git branch
_gut_branch_current() {
  # git rev-parse --abbrev-ref HEAD
  local git_branch_current=$(git branch | grep "* " | awk '{ $1=$1; print }' | tr -d "* ")
  echo "$git_branch_current"
}

# Log list - Prints the git log list
_gut_log_list() {
  local git_log_list=$(git log -n 25 --pretty=format:'%h - %s (%cd) <%an>')
  echo "$git_log_list"
}

# Log hashes - Prints the git log list of hashes
_gut_log_hash_list() {
  local git_log_hashe_list=$(git log -n 25 --pretty=format:'%h')
  echo "$git_log_hashe_list"
}

# Remote name list - Prints the list of git remote names
_gut_remote_name_list() {
  local git_remote=$(git remote)  #($(git remote -v | grep push | awk '{ print $1; }'))
  local git_remote_name_list=("$git_remote")
  echo "$git_remote_name_list"
}

# Remote url list -  Print the list of git remote urls
_gut_remote_url_list() {
  local git_remote=$(git remote -v | grep push | awk '{ print $2; }')
  local git_remote_url_list=("$git_remote")
  echo "$git_remote_url_list"
}

# Remote name url list - Print the list of git remote name with urls
_gut_remote_name_url_list() {
  local git_remote=$(git remote -v | grep push | awk '{ print $1,  "(" $2 ")" }')
  local git_remote_name_url_list=("$git_remote")
  echo "$git_remote_name_url_list"
}

# Branch count - Prints the amounts of git branches of the current directory
_gut_branch_count() {
	local output="$(git branch --list 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "$output" ]; then
		return $exit
	fi
	if [ "$output" = "0" ]; then
		return $exit
	fi

	echo "$output"
}

# Stash count - Prints the amounts of git stashes of the current directory
_gut_stash_count() {
	local output="$(git stash list 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "$output" ]; then
		return $exit
	fi

	echo "$output"
}

# Remote count - Prints the amounts of git remotes of the current directory
_gut_remote_count() {
	local output="$(git remote 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "$output" ]; then
		return $exit
	fi

	echo "$output"
}

# Status short - Prints a short summary for git status
# ^ - staged changes available
# * - unstaged changes available
# + - untracked changes available
_gut_status_short() {
  local changes=$(git status 2>/dev/null)
  local staged="Changes to be committed"
  local unstaged="Changes not staged for commit"
  local untracked="Untracked files"

  # check if output string contains keywords
  if [[ $changes == *$staged* ]]; then
    echo -n "^"
  fi

  if [[ $changes == *$unstaged* ]]; then
    echo -n "*"
  fi

  if [[ $changes == *$untracked* ]]; then
    echo -n "+"
  fi
}

# Title JSON - Sets the terminal's title with git info
_gut_title_json() {
	local current_branch=$(__git_ps1 "(%s)" | tr -d "(" | tr -d ")")
	local branch_count=$(_gut_branch_count)
	local stash_count=$(_gut_stash_count)

  # Not in a git directory
	if [ -z "$current_branch" ]; then
		echo -n -e "\033]0;\007"
		return
	fi

	local title="{branch: $current_branch, branches: $branch_count, stashes: $stash_count}"
	echo -n -e "\033]0;$title\007"
}
