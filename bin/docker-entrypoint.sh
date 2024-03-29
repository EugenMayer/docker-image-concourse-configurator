#!/bin/sh
#set -x
set -e


if [ -n "${DO_GENERATE_TSA_KEYS}" ]; then
    if [ -f ${WEB_KEY_HOME}/tsa_host_key ]; then
        echo "keys tsa exists - no need to regenerate."
    else
        echo "generating  tsa keys.."
        # we need -PEM since concourse is not compatible with newer ssh-keygen ( > alpine 3.6 )
        # see https://github.com/concourse/concourse/issues/2949
        ssh-keygen -m PEM -t rsa -f ${WEB_KEY_HOME}/tsa_host_key -N ''
        ssh-keygen -m PEM -t rsa -f ${WEB_KEY_HOME}/session_signing_key -N ''

        cp ${WEB_KEY_HOME}/tsa_host_key.pub  ${WORKER_KEY_HOME}
    fi
fi

# this could be done using the concourse generate-key binary option, @see https://concourse-ci.org/download.html#v500-note-19
# but this would need us to deploy the binary into the configurator .. and this just makes more effort then anything we gain
if [ -n "${DO_GENERATE_WORKER_KEYS}" ]; then
    if [ -f ${WORKER_KEY_HOME}/worker_key ]; then
        echo "worker keys exists - no need to regenerate."
    else
        echo "generating worker keys.."
        # we need -PEM since concourse is not compatible with newer ssh-keygen ( > alpine 3.6 )
        # see https://github.com/concourse/concourse/issues/2949
        ssh-keygen -m PEM -t rsa -f ${WORKER_KEY_HOME}/worker_key -N ''
        cp ${WORKER_KEY_HOME}/worker_key.pub ${WEB_KEY_HOME}/authorized_worker_keys
    fi
fi

echo "----------------------------------------"
echo "-------------- VAULT--------------------"
echo "----------------------------------------"

if [ -f ${VAULT_SERVER_HOME}/server.crt ]; then
    echo "vault already configured"
    if [ -n "${VAULT_DO_UNSEAL_ON_BOOT}" ]; then
        vault_unseal
    fi
elif [ -n "${VAULT_ENABLED}" ]; then
    echo "generating vault server key"
    mkdir -p ${VAULT_SERVER_HOME}
    openssl req -extensions 'v3_req' -config /etc/vault_server_cert.conf -new -newkey rsa:4096 -nodes -keyout ${VAULT_SERVER_HOME}/server.key -x509 -days 1095 -out ${VAULT_SERVER_HOME}/server.crt
	# put the server.crt into the client folder so we can validate it on concourse too - we do not mount the server folder there
	cp ${VAULT_SERVER_HOME}/server.crt ${VAULT_CONCOURSE_CLIENT_HOME}/server.crt
        echo "chown server.key so vault can access it"
        chown root:1000 ${VAULT_SERVER_HOME}/server.key
        chmod g+r ${VAULT_SERVER_HOME}/server.key

	echo "deploying vault config"
    cat << EOF > ${VAULT_SERVER_HOME}/vault.hcl
storage "file" {
    path = "/vault/file"
}
listener "tcp" {
    address = "0.0.0.0:8200"
    tls_cert_file = "/vault/config/server.crt"
    tls_key_file = "/vault/config/server.key"
}
EOF
    echo "deploying vault concourse policy"
    cat << EOF > ${VAULT_SERVER_HOME}/concourse_policy.hcl
path "sys/*" {
  capabilities = ["deny"]
}

path "secret/concourse/*" {
  capabilities = ["read"]
}
EOF
    if [ -n "${VAULT_DO_AUTOCONFIGURE}" ]; then
        echo "Auto-configuring vault"
        vault_init
    fi
fi

exec $@
