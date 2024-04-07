# This is meant to be a fix for docker 1500 MTU. Use it as your base to configure additional runner images
FROM ghcr.io/actions/actions-runner:latest

# Labels
LABEL maintainer="Sami Shakir"
LABEL org.opencontainers.image.source = "https://github.com/samis-group/homelab"

ENV DOCKER_MTU 1400

RUN sudo mv /usr/bin/docker /usr/bin/docker-wrapped
COPY docker/actions-runner-base/docker-shim.sh /usr/bin/docker
RUN sudo chmod 755 /usr/bin/docker

# Ubuntu OS dependencies
RUN apt-get update && \
    apt-get install -y curl wget jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
  chmod +x /usr/bin/yq
