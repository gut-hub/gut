#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_docker_exec" "_gut_docker_kill_all" "_gut_docker_list" "_gut_docker_remove_stopped")
GUT_EXPORT_NAMES=("docker-exec" "docker-kill-all" "docker-list" "docker-remove")
GUT_EXPORT_DESCRIPTIONS=("Exec into a docker container" "Kill all running containers" "Displays the list of docker containers" "Remove all stopped containers")

# Prompts user to select a docker container to exec into
_gut_docker_exec() {
  # Set internal field separator
  IFS=$'\n'

  # Get list of containers
  local docker_list=($(_gut_docker_list))

  # Select container
  echo "Select a container:"
  _gut_menu docker_list[@]
  local index_container=${?}

  # Get selected container
  local container=$(echo "${docker_list[index_container]}" | awk '{ print $1; }')

  echo "Enter a command to run (bash, sh, etc):"
  read -r cmd

  # Run docker command
  echo "Executing: docker exec -it ${container} ${cmd}"
  docker exec -it ${container} ${cmd}
}

# Kills all running containers
_gut_docker_kill_all() {
  docker kill $(docker ps -q)
}

# Displays the list of docker containers
_gut_docker_list() {
  local docker_list=$(docker ps -a --format '{{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}')

  echo "${docker_list}"
}

# Remove all stopped containers
_gut_docker_remove_stopped() {
  docker rm $(docker ps -a -q -f status=exited)
}
