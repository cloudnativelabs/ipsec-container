FROM alpine:latest

ENV SECRETS_DIR=/ipsec.d

RUN apk add --update --no-cache \
      strongswan \
      openssl

ADD files/ipsec.conf /etc/ipsec.conf
ADD files/ipsec.secrets /etc/ipsec.secrets
ADD generate_secrets.sh /generate_secrets.sh
ADD entrypoint.sh /entrypoint.sh

VOLUME /ipsec.secrets.d
VOLUME /ipsec.config.d
VOLUME /ipsec.d

# DHCP Relay ipv4
EXPOSE 67/udp
EXPOSE 68/udp

# DHCP Relay ipv6
EXPOSE 547/udp

# ipsec - L2TP tunnel based VPN
EXPOSE 500/udp
EXPOSE 4500/udp

# ipsec - PPTP tunnel based VPN
EXPOSE 1723/tcp

ENTRYPOINT "/entrypoint.sh"
