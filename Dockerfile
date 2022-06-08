# This is meant to be an ephemeral workspace to deploy these ansible playbooks.
# Simply run the image and run your playbooks.
FROM python:3

# VAULT_PASS is passed in as an ENV var and will be overwritten by the user (hopefully).
ENV VAULT_PASS='some_password'
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Sydney

RUN apt-get update \
  && apt-get install -y tzdata make vim openssh-server bash-completion \
  && service ssh start

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
RUN mkdir -p /home/ubuntu/.ssh /home/ubuntu/ansible/roles \
  && chown -R ubuntu:root /home/ubuntu/.ssh /home/ubuntu/ansible

# WORKDIR /home/ubuntu
WORKDIR /home/ubuntu/ansible

# Copy files and install requirements
COPY --chown=ubuntu:root requirements* ./
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r requirements.txt
COPY --chown=ubuntu:root Makefile ./
COPY --chown=ubuntu:root makefiles/ makefiles/
COPY --chown=ubuntu:root roles/requirements* roles/
USER ubuntu
RUN make reqs

COPY --chown=ubuntu:root bin/ bin/

RUN echo "alias ll='ls -alh'" >> ~/.bashrc

# Allow certain bind mounts from outside container
VOLUME [ "/home/ubuntu/.ssh", "/home/ubuntu/ansible" ]

# Open SSH because some play delegate to localhost
EXPOSE 22

# Parse the password from ENV and give us shell as default so we can do whatever
ENTRYPOINT [ "/home/ubuntu/ansible/bin/docker-entrypoint.sh" ]
