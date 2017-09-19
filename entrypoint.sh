#!/usr/bin/env sh
set -e

./generate_secrets.sh

cp -r "${SECRETS_DIR}"/private/* /etc/ipsec.d/private
cp -r "${SECRETS_DIR}"/cacerts/* /etc/ipsec.d/cacerts
cp -r "${SECRETS_DIR}"/certs/* /etc/ipsec.d/certs

ipsec start --nofork ${@}
