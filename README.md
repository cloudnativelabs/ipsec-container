# ipsec-container
Build/use this docker image to quickly spin up a StrongSwan ipsec server.

## Usage
- `docker_run_example.sh` is an example of how to use this container image.

## Tools
- `generate_secrets.sh` is a standalone script to generate server/client
  certs/keys for ipsec. The assets can then be passed into an instance of this
  container with `docker run -v $PWD/secrets:/ipsec.d [...]`. Otherwise
  you can give the `/ipsec.d` volume an empty directory in which case
  ipsec-container automatically generates these assets and stores them on your
  host.
- `entrypoint.sh` is meant only to run inside the container and is responsible
  for generating assets (if needed) and starting ipsec.
