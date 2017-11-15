#!/usr/bin/env bash
set -x
set -e

export DOCKER_IP=vault
export VAULT_ADDR=https://vault:8200
export VAULT_SKIP_VERIFY=true
vault init -check  # should return 'Vault is not initialized'
vault init -key-shares=1 -key-threshold=1 | tee -a ${VAULT_HOME}/init_output |
  awk 'BEGIN{OFS=""} /Unseal/ {print "export VAULT_UNSEAL_KEY=",$4};/Root/ {print "export VAULT_ROOT_TOKEN=",$4}' > ${VAULT_HOME}/init_vars

source ${VAULT_HOME}
vault unseal $VAULT_UNSEAL_KEY
vault auth $VAULT_ROOT_TOKEN
vault write secret/concourse/main/helloworld/from-vault value="a value from vault"
vault delete secret/concourse/main/helloworld/from-vault

echo "enabling approle"
vault auth-enable approle
vault write auth/approle/role/concourse_role secret_id_ttl=60m token_num_uses=60 token_ttl=120m token_max_ttl=300m secret_id_num_uses=400

echo ROLE_ID
echo vault read -format=json auth/approle/role/concourse_role/role-id | jq -r '.data.role_id'

echo SECRET_ID
vault write -format=json -force auth/approle/role/concourse_role/secret-id | jq -r '.data.secret_id'