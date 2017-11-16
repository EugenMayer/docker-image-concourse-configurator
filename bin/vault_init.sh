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

vault init -check || true  # should return 'Vault is not initialized'
vault init -key-shares=1 -key-threshold=1 | tee -a ${VAULT_SERVER_HOME}/init_output | awk 'BEGIN{OFS=""} /Unseal/ {print "export VAULT_UNSEAL_KEY=",$4};/Root/ {print "export VAULT_ROOT_TOKEN=",$4}' > ${VAULT_SERVER_HOME}/init_vars

echo "export VAULT_ADDR=${VAULT_ADDR}" >> ${VAULT_SERVER_HOME}/init_vars
echo "export VAULT_CACERT=${VAULT_CACERT}" >> ${VAULT_SERVER_HOME}/init_vars

source ${VAULT_SERVER_HOME}/init_vars
vault unseal  ${VAULT_UNSEAL_KEY}
vault auth  ${VAULT_ROOT_TOKEN}

# a test
vault write secret/concourse/main/helloworld/from-vault value="a value from vault"
vault delete secret/concourse/main/helloworld/from-vault

# add our concourse policy
vault policy-write concourse ${VAULT_SERVER_HOME}/concourse_policy.hcl

#echo "enabling approle"
#vault auth-enable  approle
#vault write  auth/approle/role/concourse_role secret_id_ttl=60m token_num_uses=60 token_ttl=120m token_max_ttl=300m secret_id_num_uses=400
#
#echo ROLE_ID
#vault read  -format=json auth/approle/role/concourse_role/role-id | jq -r '.data.role_id'
#
#echo SECRET_ID
#vault write  -format=json -force auth/approle/role/concourse_role/secret-id | jq -r '.data.secret_id'

echo "setting up client cert based access"
vault_client_cert

echo "deploying client certificate"
vault auth-enable  cert
vault write \
 auth/cert/certs/concourse \
 display_name=concourse \
 policies=default,concourse \
 certificate=@/vault/concourse/cert.pem \
 ttl=3600