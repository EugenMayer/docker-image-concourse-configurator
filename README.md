## WAT

This concourse-ci server helper will try to configure you concourse server right of the bat.

- generates keys for concourse and puts those onto a volume, to be shared with concourse for production use
- if vault is enabled, does the complete vault setup for you. Generating vault server cert/kets, enabling cert based auth, creating client certs and sharing those with concourse-ci-server-web so it can authenticate
It has also vault support, generating keys for the value, if you set

    -e VAULT_ENABLED=1

## Usage

Those are some examples

You find the docker image at [eugenmayer/concourse-configurator](https://hub.docker.com/r/eugenmayer/concourse-configurator)


- Use the tag for your Concourse baseline version, so `3.x`, `4.x`, `5.x`
- That is your best [starting point](https://github.com/EugenMayer/concourseci-server-boilerplate)
- For all rancher users, see [this catalog](https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates)

## Hints

Yet we do use the KV version 1 API since Concourse ( 5.4.0 as of writing ) does not support the version 2 kv (versioned values )
