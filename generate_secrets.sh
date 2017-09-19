#!/usr/bin/env sh
set -e

if [ -z "${IPSEC_FQDN}" ] || [ -z "${IPSEC_EMAIL}" ]; then
    echo "ERROR: IPSEC_FQDN and IPSEC_EMAIL environment variables are required."
    echo
    echo "Usage Example:"
    echo "IPSEC_FQDN=ipsec.example.com"
    echo "IPSEC_EMAIL=myself@example.com"
    echo "SECRETS_DIR=/etc/ipsec.d ${0}"
    echo
    echo "Note: SECRETS_DIR defaults to \"./secrets\""
    exit 1
fi

if ! command -v ipsec >/dev/null; then
    echo "ERROR: \"ipsec\" command not found."
    exit 127
fi

if ! command -v openssl >/dev/null; then
    echo "ERROR: \"openssl\" command not found."
    exit 127
fi

[ -z "${SECRETS_DIR}" ] && SECRETS_DIR="./secrets"

[ ! -d "${SECRETS_DIR}/private" ] && mkdir -p "${SECRETS_DIR}/private"
[ ! -d "${SECRETS_DIR}/cacerts" ] && mkdir -p "${SECRETS_DIR}/cacerts"
[ ! -d "${SECRETS_DIR}/certs" ]   && mkdir -p "${SECRETS_DIR}/certs"

[ -z "${SWAN_CA_KEY_PEM}" ] && SWAN_CA_KEY_PEM="strongswanKey.pem"
if [ -f "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}"
    ipsec pki --gen --type rsa --size 4096 --outform pem \
        > "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}"
    chmod 600 "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}"
fi

[ -z "${SWAN_CA_CERT_PEM}" ] && SWAN_CA_CERT_PEM="strongswanCert.pem"
if [ -f "${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}"
    ipsec pki --self --ca --lifetime 3650 --outform pem \
        --in "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}" --type rsa \
        --dn "C=CH, O=strongSwan, CN=strongSwan Root CA" \
        > "${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}"
    chmod 600 "${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}"
fi

[ -z "${SWAN_HOST_KEY_PEM}" ] && SWAN_HOST_KEY_PEM="vpnHostKey.pem"
if [ -f "${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}"
    ipsec pki --gen --type rsa --size 2048 --outform pem \
        > ${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}
    chmod 600 ${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}
fi

[ -z "${SWAN_HOST_CERT_PEM}" ] && SWAN_HOST_CERT_PEM="vpnHostCert.pem"
if [ -f "${SECRETS_DIR}/certs/${SWAN_HOST_CERT_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/certs/${SWAN_HOST_CERT_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/certs/${SWAN_HOST_CERT_PEM}"
    ipsec pki --pub --in "${SECRETS_DIR}/private/${SWAN_HOST_KEY_PEM}" --type rsa | \
        ipsec pki --issue --lifetime 730 --outform pem \
        --cacert "${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}" \
        --cakey "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}" \
        --dn "C=CH, O=strongSwan, CN=${IPSEC_FQDN}" \
        --san "${IPSEC_FQDN}" \
        --flag serverAuth --flag ikeIntermediate \
        > "${SECRETS_DIR}/certs/${SWAN_HOST_CERT_PEM}"
fi

[ -z "${SWAN_CLIENT_KEY_PEM}" ] && SWAN_CLIENT_KEY_PEM="ClientKey.pem"
if [ -f "${SECRETS_DIR}/private/${SWAN_CLIENT_KEY_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/private/${SWAN_CLIENT_KEY_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/private/${SWAN_HOST_CERT_PEM}"
    ipsec pki --gen --type rsa --size 2048 --outform pem \
        > "${SECRETS_DIR}/private/${SWAN_CLIENT_KEY_PEM}"
    chmod 600 "${SECRETS_DIR}/private/${SWAN_CLIENT_KEY_PEM}"
fi

[ -z "${SWAN_CLIENT_CERT_PEM}" ] && SWAN_CLIENT_CERT_PEM="ClientCert.pem"
if [ -f "${SECRETS_DIR}/certs/${SWAN_CLIENT_CERT_PEM}" ]; then
    echo "INFO: ${SECRETS_DIR}/certs/${SWAN_CLIENT_CERT_PEM}"
    echo "INFO: File already exists. Moving on."
else
    echo "INFO: Generating ${SECRETS_DIR}/certs/${SWAN_HOST_CERT_PEM}"
    ipsec pki --pub --in "${SECRETS_DIR}/private/${SWAN_CLIENT_KEY_PEM}" --type rsa | \
        ipsec pki --issue --lifetime 730 --outform pem \
        --cacert "${SECRETS_DIR}/cacerts/${SWAN_CA_CERT_PEM}" \
        --cakey "${SECRETS_DIR}/private/${SWAN_CA_KEY_PEM}" \
        --dn "C=CH, O=strongSwan, CN=${IPSEC_EMAIL}" \
        --san "${IPSEC_EMAIL}" \
        > "${SECRETS_DIR}/certs/${SWAN_CLIENT_CERT_PEM}"
fi

echo "Done!"
