# This is meant to be a fix for docker 1500 MTU. Use it as your base to configure additional runner images
FROM ghcr.io/actions/actions-runner:latest

# Labels
LABEL maintainer="Sami Shakir"
LABEL org.opencontainers.image.source = "https://github.com/samis-group/homelab"

ENV DOCKER_MTU 1400

RUN sudo mv /bin/docker /bin/docker-wrapped
COPY docker/actions-runner-base/docker-shim.sh /bin/docker
