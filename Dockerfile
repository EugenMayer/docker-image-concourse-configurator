# we cannot switch to alpine 3.10 due to https://github.com/vishnubob/wait-for-it/issues/5
FROM alpine:3.14

LABEL org.opencontainers.image.source https://github.com/EugenMayer/docker-image-concourse-configurator

ENV DO_GENERATE_TSA_KEYS=1
ENV DO_GENERATE_WORKER_KEYS=1
ENV WEB_KEY_HOME=/concourse-keys/web
ENV WORKER_KEY_HOME=/concourse-keys/worker
ENV VAULT_SERVER_HOME=/vault/server
ENV VAULT_CONCOURSE_CLIENT_HOME=/vault/concourse
ENV VAULT_SUBJECT="/CN=vault"

# use this in docker-compose if you want to activate vault
#ENV VAULT_ENABLED=1
ENV VAULT_DO_AUTOCONFIGURE=1
# if set, the vault is unsealed automically when the server gets restarted
# otherwise you have to do it yourself
ENV VAULT_DO_UNSEAL_ON_BOOT=1

RUN apk add --update \
  bash \
  ca-certificates \
  openssl \
  openssh-keygen \
  curl \
  jq \
  unzip \
  && mkdir -p ${WORKER_KEY_HOME} ${WEB_KEY_HOME} ${VAULT_SERVER_HOME} ${VAULT_CONCOURSE_CLIENT_HOME} \
  && curl --location --retry 3 --silent https://releases.hashicorp.com/vault/1.8.2/vault_1.8.2_linux_amd64.zip -o /tmp/vault.zip \
  && cd /tmp && unzip vault.zip \
  && mv /tmp/vault /usr/local/bin/vault \
  # Clean caches and tmps
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/*  \
  && rm -rf /var/log/*

ADD bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ADD bin/wait-for-it.sh /usr/local/bin/wait-for-it
ADD bin/busyscript.sh /usr/local/bin/busyscript
ADD bin/vault_client_cert.sh /usr/local/bin/vault_client_cert
ADD bin/vault_init.sh /usr/local/bin/vault_init
ADD bin/vault_unseal.sh /usr/local/bin/vault_unseal
ADD vault_client_cert.conf /etc/vault_client_cert.conf
ADD vault_server_cert.conf /etc/vault_server_cert.conf

RUN chmod +x \
  /usr/local/bin/docker-entrypoint.sh \
  /usr/local/bin/vault_init \
  /usr/local/bin/vault_init \
  /usr/local/bin/vault_client_cert \
  /usr/local/bin/vault_unseal \
  /usr/local/bin/wait-for-it \
  && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
VOLUME [ "${WEB_KEY_HOME}","${WORKER_KEY_HOME}", "${VAULT_SERVER_HOME}", "${VAULT_CONCOURSE_CLIENT_HOME}" ]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/busyscript"]
