#!/usr/bin/env bash

# Sets a key/value string in ENV
# @param {string} key - Key to set
# @param {string} value - Value to set
_gut_env_set() {
  local key=${1}
  local value=${2}

  if [ "${key}" = "" ]; then
    echo "[gut-env-set] No key provided"
    return 1;
  fi
  if [ "${value}" = "" ]; then
    echo "[gut-env-set] No value provided"
    return 1;
  fi

  export "${key}=${value}"
}

# Retrieves a key/value string from ENV
# @param {string} key - Key to set
# @return {string} value - Value to set
_gut_env_get() {
  local key=${1}

  # Check arguments
  if [ "${key}" = "" ]; then
    echo "[gut-env-get] No key provided"
    return 1;
  fi

  echo "${!key}"
}
