FROM alpine:latest

RUN apk add --update --no-cache strongswan

# mkdir -p /etc/ipsec.secrets.d/ && \
# mkdir -p /etc/ipsec.config.d/

ADD files/ipsec.conf /etc/ipsec.conf
ADD files/ipsec.secrets /etc/ipsec.secrets

VOLUME /etc/ipsec.secrets.d
VOLUME /etc/ipsec.config.d

CMD ipsec start --nofork
