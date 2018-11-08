#!/usr/bin/env bash

# Vars
GUT_EXPORT_FUNCTIONS=("_gut_cert_check")
GUT_EXPORT_NAMES=("cert-check")
GUT_EXPORT_DESCRIPTIONS=("Displays the certificate expiration date of the host")

# Displays the certificate expiration date of the host
# @param {string} host - Host to check
_gut_cert_check() {
  local host=${1}

  # Check arguments
  if [ "${host}" = "" ]; then
    echo "[gut-cert-check] No host provided"
    return 1;
  fi

  local expires=$(echo | openssl s_client -servername "${host}" -connect "${host}":443 2>/dev/null | openssl x509 -noout -dates | awk -F "=" '{print $2}')

  echo "${expires}"
}
