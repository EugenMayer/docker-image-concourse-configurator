#!/usr/bin/env bash
# set -x
set -e

source ${VAULT_SERVER_HOME}/init_vars
wait-for-it -h vault -p 8200
echo "..vault up"
echo "unsealing"
vault operator unseal ${VAULT_UNSEAL_KEY}
echo "done"
vault login ${VAULT_ROOT_TOKEN} > /dev/null
