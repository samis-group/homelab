FROM ghcr.io/actions/actions-runner:latest
RUN sudo mv /bin/docker /bin/docker-wrapped
COPY docker/runner/docker /bin/docker
ENV DOCKER_MTU 1450
