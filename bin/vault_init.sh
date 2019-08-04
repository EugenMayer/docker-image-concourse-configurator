#!/usr/bin/env bash
# set -x
set -e

# for more see https://www.vaultproject.io/docs/commands/environment.html
export VAULT_ADDR=https://vault:8200
export VAULT_SKIP_VERIFY=true
export VAULT_CACERT=/vault/server/server.crt

echo "waiting for vault to start up.."
wait-for-it -h vault -p 8200
echo "..vault up"

vault operator init -status || true  # should return 'Vault is not initialized'
vault operator init -key-shares=1 -key-threshold=1 | tee -a ${VAULT_SERVER_HOME}/init_output | awk 'BEGIN{OFS=""} /Unseal/ {print "export VAULT_UNSEAL_KEY=",$4};/Root/ {print "export VAULT_ROOT_TOKEN=",$4}' > ${VAULT_SERVER_HOME}/init_vars

echo "export VAULT_ADDR=${VAULT_ADDR}" >> ${VAULT_SERVER_HOME}/init_vars
echo "export VAULT_CACERT=${VAULT_CACERT}" >> ${VAULT_SERVER_HOME}/init_vars

source ${VAULT_SERVER_HOME}/init_vars
vault operator unseal  ${VAULT_UNSEAL_KEY}
vault login ${VAULT_ROOT_TOKEN}
# TODO: yet disabled version=2 since it is not yet supported by concourse
# vault secrets enable -version=2 -path=secret kv
vault secrets enable -version=1 -path=secret kv
# this does the  upgrade from < 1.1.0 to a versions kv storage
# TODO: yet disabled version=2 since it is not yet supported by concourse
# vault kv enable-versioning secret/ > /dev/null 2>&1 || true 

# a test
echo "trying to test write ops on vault"
vault kv put secret/concourse/main/helloworld/from-vault value="a value from vault"
vault kv delete secret/concourse/main/helloworld/from-vault

# add our concourse policy
vault policy write concourse ${VAULT_SERVER_HOME}/concourse_policy.hcl

echo "setting up client cert based access"
vault_client_cert

echo "deploying client certificate"
vault auth enable cert
vault write \
 auth/cert/certs/concourse \
 display_name=concourse \
 policies=default,concourse \
 certificate=@/vault/concourse/cert.pem \
 ttl=36000
