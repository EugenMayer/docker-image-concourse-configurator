#!/usr/bin/env bash
# set -x
set -e

echo "creating client certificate"
openssl req -config /etc/vault_client_cert.conf -x509 -newkey rsa:2048 -keyout ${VAULT_CONCOURSE_CLIENT_HOME}/key.pem -out ${VAULT_CONCOURSE_CLIENT_HOME}/cert.pem -days 365