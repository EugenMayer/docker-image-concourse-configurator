#!/bin/sh

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

exec $@