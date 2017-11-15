FROM alpine:3.6

ENV WEB_KEY_HOME=/concourse-keys/web
ENV WORKER_KEY_HOME=/concourse-keys/worker
ENV VAULT_HOME=/concourse-keys/vault
ENV VAULT_SUBJECT="/C=DE/ST=NS/L=Hannover/O=KontextWork/OU=IT/CN=vault"

#ENV VALUT_DO_GENERATE=1
ADD bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ADD bin/busyscript.sh /usr/local/bin/busyscript
ADD bin/vault_init.sh /usr/local/bin/vault_init

RUN apk add --update \
      bash \
      ca-certificates \
      openssl \
      openssh-keygen \
      curl \
      jq \
      unzip \
    && mkdir -p ${WORKER_KEY_HOME} ${WEB_KEY_HOME} ${VALUT_HOME} \
    && chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/vault_init /usr/local/bin/vault_init \
    && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh \
    && curl --location --retry 3 --silent https://releases.hashicorp.com/vault/0.9.0/vault_0.9.0_linux_amd64.zip -o /tmp/vault.zip \
    && cd /tmp && unzip vault.zip \
    && mv /tmp/vault /usr/local/bin/vault \
    # Clean caches and tmps
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*  \
    && rm -rf /var/log/*

VOLUME [ "${WEB_KEY_HOME}","${WORKER_KEY_HOME}", "${VAULT_HOME}" ]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/busyscript"]
