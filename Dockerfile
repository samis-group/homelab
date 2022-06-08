# This is meant to be an ephemeral workspace to deploy these ansible playbooks.
# Simply run the image and run your playbooks.
FROM python:3

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
ARG DEBIAN_FRONTEND=noninteractive
# Set TZ
ENV TZ=Australia/Sydney

# Ubuntu OS dependencies
RUN apt-get update \
  && apt-get install -y tzdata make vim openssh-server bash-completion sudo

# Run as user
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 ubuntu \
  && echo "ubuntu:ubuntu" | chpasswd

# Make required directories and chown them
RUN mkdir -p /home/ubuntu/.ssh /home/ubuntu/ansible/roles \
  && chown -R ubuntu:root /home/ubuntu/.ssh /home/ubuntu/ansible \
# Also ensure sudo group users are not asked for a password when using sudo command
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /home/ubuntu/ansible

# Copy files and install requirements
COPY --chown=ubuntu:root requirements* ./
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r requirements.txt
COPY --chown=ubuntu:root Makefile ./
COPY --chown=ubuntu:root makefiles/ makefiles/
COPY --chown=ubuntu:root roles/requirements* roles/
# Install ansible requirements as the user that will execute them
# otherwise they get stored in system files and this is the easiest way
USER ubuntu
RUN make reqs
# Copy bin files (mainly for docker-entrypoint.sh)
COPY --chown=ubuntu:root bin/ bin/

# Setup aliases
RUN echo "alias ll='ls -alh'" >> ~/.bashrc

# Allow certain bind mounts from outside container
VOLUME [ "/home/ubuntu/.ssh", "/home/ubuntu/ansible" ]

# Some plays delegate to localhost, requires access to itself on ssh
EXPOSE 22

# Parse the password from ENV and give us shell as default so we can do whatever
ENTRYPOINT [ "/home/ubuntu/ansible/bin/docker-entrypoint.sh" ]
