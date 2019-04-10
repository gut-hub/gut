#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_kv_get" "_gut_kv_set")
GUT_EXPORT_NAMES=("get" "set")
GUT_EXPORT_DESCRIPTIONS=("Retrieves a key/value string" "Stores a key/value string")

# Stores a key/value string
# @param {string} file_path - Location of file to store
# @param {string} key - Key to store
# @param {string} value - Value to store
_gut_kv_set() {
  local file_path=${1}
  local key=${2}
  local value=${3}

  # Check arguments
  if [ "${file_path}" = "" ]; then
    echo "[gut-kv-set] No file path provided"
    return 1;
  fi
  if [ "${key}" = "" ]; then
    echo "[gut-kv-set] No key provided"
    return 1;
  fi
  if [ "${value}" = "" ]; then
    echo "[gut-kv-set] No value provided"
    return 1;
  fi

  # Encode key and value
  local encoded_key=$(echo "${key}" | base64)
  local encoded_value=$(echo "${value}" | base64)
  local store="${encoded_key}:${encoded_value}"

  # Check if file exists
  if [ ! -e "${file_path}" ]; then
    # File does not exist, store
    echo ${store} >> ${file_path}
    return 0
  fi

  # Check if key exists
  local found=$(grep "${encoded_key}:" "${file_path}")
  local found_line=$(awk "/"${encoded_key}:"/{ print NR; exit }" "${file_path}")
  if [ "${found}" ]; then
    # Key found, update current key
    local awk_cmd="{ if (NR == "${found_line}") print \""${store}"\"; else print \$0}"
    awk "${awk_cmd}" "${file_path}" > "${file_path}".swap
    cat "${file_path}".swap > "${file_path}"
    rm "${file_path}".swap
  else
    # Key not found, append key
    echo ${store} >> ${file_path}
  fi
}

# Retrieves a key/value string
# @param {string} file_path - Location of file to store
# @param {string} key - Key to store
# @return {string} value - Value to store
_gut_kv_get() {
  local file_path=${1}
  local key=${2}

  # Check arguments
  if [ "${file_path}" = "" ]; then
    echo "[gut-kv-get] No file path provided"
    return 1;
  fi
  if [ "${key}" = "" ]; then
    echo "[gut-kv-get] No key provided"
    return 1;
  fi

  # Check if file exists
  if [ ! -e "${file_path}" ]; then
    # File does not exist, return
    echo "[gut-kv-get] File does not exist"
    return 1
  fi

  # Encode key
  local encoded_key=$(echo "${key}" | base64)

  # Check if key exists
  local found=$(grep "${encoded_key}:" "${file_path}")
  local found_line=$(awk "/"${encoded_key}:"/{ print \$0; exit }" "${file_path}")
  if [ "${found}" ]; then
    # Key found, get key and decode it
    local encoded_value=$(echo "${found_line}" | awk -F':' "{ print \$2 }")
    local value=$(echo "${encoded_value}" | base64 -D)
    echo ${value}
  fi
}
