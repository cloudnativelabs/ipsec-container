#!/usr/bin/env sh
set -e

docker run \
    -it \
    --rm \
    --privileged \
    --net=host \
    --cap-add=NET_ADMIN \
    -v "/lib/modules:/lib/modules" \
    -v "${PWD}/secrets:/ipsec.d" \
    -e "IPSEC_FQDN=ipsec.example.com" \
    -e "IPSEC_EMAIL=myself@example.com" \
    quay.io/cloudnativelabs/ipsec
