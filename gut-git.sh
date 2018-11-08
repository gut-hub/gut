#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_git_log_colored" "_gut_git_fetch" "_gut_git_pull" "_gut_git_push" "_gut_git_reset")
GUT_EXPORT_NAMES=("log" "fetch" "pull" "push" "reset")
GUT_EXPORT_DESCRIPTIONS=("Displays the git log" "Fetches the selected remote repo" "Pulls the selected remote branch" "Pushes the current branch to the selected remote repo" "Soft resets on the selected git hash")

# Prints the git log
_gut_git_log_colored() {
  # Git format placeholders
  # %h: abbreviated commit hash
  # %s: subject
  # %cd: committer date
  # %an: author name
  git log -n 25 --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# Fetches the selected remote repo
_gut_git_fetch() {
  # Set internal field separator
  IFS=$'\n'

  # Get git remotes
  local git_remote_name=($(_gut_git_remote_name))
  local git_remote_name_url=($(_gut_git_remote_name_url))
  # git fetch <remote> -v 2>&1 | grep "=" | awk '{ print $5; }' or awk '{ print $7; }' for name/branch

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url[@]
  local index_remote=${?}

  # Run git command
  echo "Executing: git fetch --tags ${git_remote_name[$index_remote]}"
  git fetch --tags "${git_remote_name[$index_remote]}"
}

# Pulls the selected remote branch
_gut_git_pull() {
  # Set internal field separator
  IFS=$'\n'

  # Get git remotes
  local git_remote_name=($(_gut_git_remote_name))
  local git_remote_name_url=($(_gut_git_remote_name_url))

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url[@]
  local index_remote=${?}

  # Get branch from remote
  local git_branch_from_remote_full=($(_gut_git_branch_from_remote_full ${git_remote_name[$index_remote]}))
  local git_branch_from_remote=($(_gut_git_branch_from_remote ${git_remote_name[$index_remote]}))

  # Select branch
  echo "Select a branch:"
  _gut_menu git_branch_from_remote_full[@]
  local index_branch=${?}

  # Run git command
  echo "Executing: git pull ${git_remote_name[$index_remote]} ${git_branch_from_remote[$index_branch]}"
  git pull "${git_remote_name[$index_remote]}" "${git_branch_from_remote[$index_branch]}"
}

# Pushes the current branch to the selected remote repo
_gut_git_push() {
  # Set internal field separator
  IFS=$'\n'

  # Get git remotes
  local git_remote_name=($(_gut_git_remote_name))
  local git_remote_name_url=($(_gut_git_remote_name_url))

  # Select remote
  echo "Select a remote:"
  _gut_menu git_remote_name_url[@]
  local index_remote=${?}

  # Get current git branch
  local git_branch_current=$(_gut_git_branch_current)

  # Run git command
  echo "Executing: git push ${git_remote_name[$index_remote]} ${git_branch_current}"
  git push "${git_remote_name[$index_remote]}" "$git_branch_current"
  local exit_code=${?}

  if [ "${exit_code}" != "0" ]; then
    echo "Push failed, force push?"

    local _force=(No Yes)

    _gut_menu _force[@]
    local index_force=${?}

    if [ "${index_force}" = "1" ]; then
      echo "Executing: git push ${git_remote_name[$index_remote]} ${git_branch_current} --force"
      git push "${git_remote_name[$index_remote]}" "${git_branch_current}" --force
    fi
  fi
}

# Soft resets on the selected git hash
_gut_git_reset() {
  # Set internal field separator
  IFS=$'\n'

  # Get git commits
  local git_log=($(_gut_git_log))
  local git_log_hash=($(_gut_git_log_hash))

  # Select commit
  echo "Select a commit:"
  _gut_menu git_log[@]
  local index_commit=${?}

  # Run git command
  echo "Executing: git reset --soft ${git_log_hash[$index_commit]}"
  git reset --soft ${git_log_hash[$index_commit]}
}

# Prints the git branch list
_gut_git_branch() {
  local git_branch=$(git branch | awk '{ $1=$1; print }' | tr -d "* ")
  echo "${git_branch}"
}

# Prints the current git branch
_gut_git_branch_current() {
  # git rev-parse --abbrev-ref HEAD
  local git_branch=$(git branch | grep "* " | awk '{ $1=$1; print }' | tr -d "* ")
  echo "${git_branch}"
}

# Prints the git branch list of a remote branch
_gut_git_branch_from_remote() {
  # Fail if no remote name is provided
  if [ -z "${1}" ]; then
    echo "invalid parameter passed: _gut_git_branch_from_remote"
    return -1
  fi

  local git_branch=$(git branch -a | grep "${1}/" | tr -d "* " | awk -F / '{ print $3; }')
  echo "${git_branch}"
}

# Prints the git branch list of a remote branch full description
_gut_git_branch_from_remote_full() {
  # Fail if no remote name is provided
  if [ -z "${1}" ]; then
    echo "invalid parameter passed: _gut_git_branch_from_remote_full"
    return -1
  fi

  local git_branch=$(git branch -a | grep "${1}/" | tr -d "* ")
  echo "${git_branch}"
}

# Prints the git log
_gut_git_log() {
  local git_log=$(git log -n 25 --pretty=format:'%h - %s (%cd) <%an>')
  echo "${git_log}"
}

# Prints the git log hashes
_gut_git_log_hash() {
  local git_log=$(git log -n 25 --pretty=format:'%h')
  echo "${git_log}"
}

# Prints the list of git remote names
_gut_git_remote_name() {
  local git_remote=$(git remote) #($(git remote -v | grep push | awk '{ print $1; }'))
  echo "${git_remote}"
}

# Print the list of git remote name with urls
_gut_git_remote_name_url() {
  local git_remote=$(git remote -v | grep push | awk '{ print $1,  "(" $2 ")" }')
  echo "${git_remote}"
}

# Print the list of git remote urls
_gut_git_remote_url() {
  local git_remote=$(git remote -v | grep push | awk '{ print $2; }')
  echo "${git_remote}"
}

# Prints the count of git branches of the current directory
_gut_git_count_branch() {
	local count="$(git branch --list 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "${count}" ]; then
		return ${exit}
	fi
	if [ "${count}" = "0" ]; then
		return ${exit}
	fi

	echo "${count}"
}

# Prints the count of git stashes of the current directory
_gut_git_count_stash() {
	local count="$(git stash list 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "${count}" ]; then
		return ${exit}
	fi

	echo "${count}"
}

# Prints the count of git remotes of the current directory
_gut_git_count_remote() {
	local count="$(git remote 2>/dev/null | wc -l | sed 's/^ *//')"

	if [ -z "${count}" ]; then
		return ${exit}
	fi

	echo "${count}"
}

# Prints current branch for PS1 usage
_gut_git_ps1_branch_current() {
  local branch=$(cat .git/HEAD 2>/dev/null | awk -F refs/heads/ '{ print $2; }')

  if [[ -n ${branch} ]]; then
    echo "${branch}"
  else
    # Fallback
    local ref=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if [[ "${ref}" == "HEAD" ]]; then
      ref=$(git rev-parse --short HEAD)
    fi

    if [[ -n ${ref} ]]; then
      echo "${ref}"
    fi
  fi
}

_gut_git_branch_ps1() {
  local branch; local sc; local su;

  # Check for valid branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
      # Check for detatchment
      if [[ "$branch" == "HEAD" ]]; then
          # Set the branch to be the short hash
          git_branch=" (#$(git rev-parse --short HEAD))"
      else
          # Check for staged changes
          git diff --no-ext-diff --quiet || su="*"
          git diff --no-ext-diff --cached --quiet || sc="+"
          # Check for separate state
          if [[ "$sc" != "" || "$su" != "" ]]; then
              git_branch=" ($branch $su$sc)"
          else
              git_branch=" ($branch)"
          fi
      fi
  else
      git_branch=""
  fi

  echo "${git_branch}"
}

# Prints a short summary for git status
# ^ - staged changes available
# * - unstaged changes available
# + - untracked changes available
_gut_git_status_short() {
  local changes=$(git status 2>/dev/null)
  local staged="Changes to be committed"
  local unstaged="Changes not staged for commit"
  local untracked="Untracked files"

  # Check if output string contains keywords
  if [[ ${changes} == *${staged}* ]]; then
    echo -n "^"
  fi

  if [[ ${changes} == *${unstaged}* ]]; then
    echo -n "*"
  fi

  if [[ ${changes} == *${untracked}* ]]; then
    echo -n "+"
  fi
}

# Sets the terminal's title with git info
_gut_git_title_json() {
	local current_branch=$(__git_ps1 "(%s)" | tr -d "(" | tr -d ")")
	local branch_count=$(_gut_git_count_branch)
	local stash_count=$(_gut_git_count_stash)

  # Not in a git directory
	if [ -z "${current_branch}" ]; then
		echo -n -e "\033]0;\007"
		return
	fi

	local title="{branch: ${current_branch}, branches: ${branch_count}, stashes: ${stash_count}}"
	echo -n -e "\033]0;${title}\007"
}
