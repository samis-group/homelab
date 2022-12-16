# This is meant to be an ephemeral workspace to deploy these ansible playbooks.
# This dockerfile is built in ci/cd pipelines and pushed to a registry every single time a new commit is pushed.
# So it is designed to be as efficient as possible, at building from docker cache.
# With that said, once the container is built, simply run your playbooks from make targets or manually.
FROM python:3

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
ARG DEBIAN_FRONTEND=noninteractive
# Set TZ
ENV TZ=Australia/Sydney
ENV ANSIBLE_ROLES_PATH=/ansible/roles
# Run as 1000 by default unless passed in
ARG UID=1000
ARG UNAME=ubuntu

# Ubuntu OS dependencies
RUN apt-get update \
  && apt-get install -y wget unzip tzdata make vim openssh-server bash-completion sudo sshpass \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Setup container to run as user specified in build args with same password
RUN useradd -rm -d /home/$UNAME -s /bin/bash -g root -G sudo -u $UID $UNAME \
  && echo "$UNAME:$UNAME" | chpasswd

# Make required directories and chown them
RUN mkdir -p /home/$UNAME/.ssh /root/.ssh /ansible/roles \
  && chown -R $UNAME:root /home/$UNAME/.ssh /ansible \
# Also ensure sudo group users are not asked for a password when using sudo command
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /ansible

# Copy files and install requirements
COPY --chown=$UNAME:root requirements* ./
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r requirements.txt
COPY --chown=$UNAME:root Makefile ./
COPY --chown=$UNAME:root makefiles/ makefiles/
COPY --chown=$UNAME:root roles/requirements* roles/
RUN make setup-docker
# Copy bin files (mainly for docker-entrypoint.sh)
COPY --chown=$UNAME:root bin/ bin/

USER $UNAME
WORKDIR /ansible/repo

# Some plays delegate to localhost, requires access to itself on ssh
EXPOSE 22

# Parse the password from ENV and give us shell as default so we can do whatever
ENTRYPOINT [ "/ansible/bin/docker-entrypoint.sh" ]
