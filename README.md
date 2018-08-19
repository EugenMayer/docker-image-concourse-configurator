## WAT

This concourse-ci server helper will try to configure you concourse server right of the bat.

- generates keys for concourse and puts those onto a volume, to be shared with concourse for production use
- if vault is enabled, does the complete vault setup for you. Generating vault server cert/kets, enabling cert based auth, creating client certs and sharing those with concourse-ci-server-web so it can authenticate
It has also vault support, generating keys for the value, if you set

    -e VAULT_ENABLED=1

## Usage

Those are some examples

- https://github.com/EugenMayer/concourseci-server-boilerplate - that is your best starting point
- https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates - if you rancher, you are set to go
