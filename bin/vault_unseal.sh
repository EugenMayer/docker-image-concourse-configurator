#!/usr/bin/env bash
# set -x
set -e

source ${VAULT_SERVER_HOME}/init_vars
wait-for-it -h vault -p 8200
echo "..vault up"

vault unseal  ${VAULT_UNSEAL_KEY}