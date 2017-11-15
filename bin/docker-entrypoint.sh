#!/bin/sh
set -x
set -e

if [ -f ${WEB_KEY_HOME}/tsa_host_key ]; then
    echo "keys exists - no need to regenerate."
else
    echo "generating keys.."
    ssh-keygen -t rsa -f ${WEB_KEY_HOME}/tsa_host_key -N ''
    ssh-keygen -t rsa -f ${WEB_KEY_HOME}/session_signing_key -N ''

    ssh-keygen -t rsa -f ${WORKER_KEY_HOME}/worker_key -N ''

    cp ${WORKER_KEY_HOME}/worker_key.pub ${WEB_KEY_HOME}/authorized_worker_keys
    cp ${WEB_KEY_HOME}/tsa_host_key.pub  ${WORKER_KEY_HOME}
fi

if [ -n "${VALUT_DO_GENERATE}" ]; then
    mkdir -p ${VAULT_HOME}
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${VAULT_HOME}/server.key -x509 -days 365 -out ${VAULT_HOME}/server.crt -subj ${VAULT_SUBJECT}
    cat << EOF > ${VAULT_HOME}/vault.hcl
storage "file" {
    path = "/vault/file"
}
listener "tcp" {
    address = "0.0.0.0:8200"
    tls_cert_file = "/vault/config/server.crt"
    tls_key_file = "/vault/config/server.key"
}

    cat << EOF > ${VAULT_HOME}/concourse_policy.hcl
path "sys/*" {
  policy = "deny"
}

path "secret/concourse/*" {
  policy = "read"
}
EOF

fi

exec $@