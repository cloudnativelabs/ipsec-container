FROM alpine:latest

VOLUME /ipsec.secrets.d
VOLUME /ipsec.config.d
VOLUME /ipsec.d

ENV SECRETS_DIR=/ipsec.d

RUN apk add --update --no-cache \
      strongswan \
      openssl

ADD files/ipsec.conf /etc/ipsec.conf
ADD files/ipsec.secrets /etc/ipsec.secrets
ADD generate_secrets.sh /generate_secrets.sh
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"
