FROM alpine:3.6

ENV WEB_KEY_HOME=/concourse-keys/web
ENV WORKER_KEY_HOME=/concourse-keys/worker

ADD bin/docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --update \
      ca-certificates \
      openssl \
      openssh-keygen \
    && mkdir -p ${WORKER_KEY_HOME} ${WEB_KEY_HOME} \
    && chmod +x /docker-entrypoint.sh \
    # Clean caches and tmps
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*  \
    && rm -rf /var/log/*

ENTRYPOINT '/docker-entrypoint.sh'
VOLUME [ "${WEB_KEY_HOME}","${WORKER_KEY_HOME}" ]
