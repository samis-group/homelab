# This is meant to be an ephemeral workspace to deploy these ansible playbooks.
# This dockerfile is built in ci/cd pipelines and pushed to a registry every single time a new commit is pushed.
# So it is designed to be as efficient as possible, at building from docker cache.
# With that said, once the container is built, simply run your playbooks from make targets or manually.
FROM python:3

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
ARG DEBIAN_FRONTEND=noninteractive
# Set TZ
ENV TZ=Australia/Sydney
# Run as 1000 by default unless passed in
ENV USER_NAME=ubuntu
ENV GROUP_NAME=ubuntu
ENV USER_ID=1000
ENV GROUP_ID=1000

# Ubuntu OS dependencies
RUN apt-get update \
  && apt-get install -y curl wget unzip tzdata vim openssh-server bash-completion sudo gosu sshpass \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install go-task
RUN curl -L https://github.com/go-task/task/releases/download/v3.21.0/task_linux_amd64.tar.gz | \
    tar -C /usr/local/bin -xzf -

# Install Terraform
ENV TERRAFORM_VERSION=1.3.9
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Doppler CLI tools
RUN curl -Ls https://cli.doppler.com/install.sh | sh

# Setup user specified in build args allowing us to change this in the entrypoint at runtime for mounting our volumes
RUN groupadd -g ${GROUP_ID} ${GROUP_NAME} && \
  useradd -u ${USER_ID} -g ${GROUP_ID} -G sudo -s /bin/bash -m ${USER_NAME} && \
  echo "${USER_NAME}:${USER_NAME}" | chpasswd

# Make required directories and chown them
RUN mkdir -p /home/${USER_NAME}/.ssh /root/.ssh ./roles \
  && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh \
# Also ensure sudo group users are not asked for a password when using sudo command
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/${USER_NAME}

# Installs Ansible, pre-commit-hooks, molecule, along with other pip dependencies.
COPY --chown=${USER_NAME}:${GROUP_NAME} requirements.txt ./
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r ./requirements.txt

# Copy ansible requirements and install them
COPY --chown=${USER_NAME}:${GROUP_NAME} provision/ansible/requirements.yml ./
COPY --chown=${USER_NAME}:${GROUP_NAME} provision/ansible/roles/requirements.yml ./roles/

RUN mkdir -p /usr/share/ansible/collections && \
  mkdir -p /usr/share/ansible/roles && \
  ansible-galaxy collection install -r ./requirements.yml --collections-path /usr/share/ansible/collections && \
  ansible-galaxy role install -r ./roles/requirements.yml --roles-path /usr/share/ansible/roles

# Copy bin files (mainly for docker-entrypoint.sh)
COPY bin/ /usr/local/bin

# Some plays delegate to localhost, requires access to itself on ssh
EXPOSE 22

# Parse the password from ENV and give us shell as default so we can do whatever
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
