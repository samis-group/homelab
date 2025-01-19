# This is meant to be an ephemeral workspace to deploy these ansible playbooks.
# This dockerfile is built in ci/cd pipelines and pushed to a registry every single time a new commit is pushed.
# So it is designed to be as efficient as possible, at building from docker cache.
# With that said, once the container is built, simply run your playbooks from make targets or manually.
FROM python:3

# Labels
LABEL maintainer="Sami Shakir"
LABEL org.opencontainers.image.source = "https://github.com/samis-group/homelab"

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
ARG DEBIAN_FRONTEND=noninteractive
# Set TZ
ENV TZ=Australia/Sydney
# Ensure doppler secrets aren't stored in shell history.
ENV HISTIGNORE='*doppler secrets set*'

# Ubuntu OS dependencies
RUN apt-get update \
    && apt-get install -y curl wget unzip tzdata vim openssh-server bash-completion sudo gosu sshpass jq gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install go-task
RUN curl -L https://github.com/go-task/task/releases/download/v3.21.0/task_linux_amd64.tar.gz | \
    tar -C /usr/local/bin -xzf -

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
  chmod +x /usr/bin/yq

# Install Terraform
RUN TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest \
    | jq -r '.tag_name' | sed 's/v//') && \
    curl -LO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Doppler CLI tools
RUN curl -Ls https://cli.doppler.com/install.sh | sh

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# Install helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Flux cli
RUN curl -s https://fluxcd.io/install.sh | sudo bash

# Setup user inside container, allowing us to change this UID in the entrypoint at container runtime
# for mounting our volumes to match the host filesystem with correct UID/GID permissions
ENV USER_NAME=ubuntu
# Run as 1000 by default unless passed in
ENV USER_ID=1000
ENV GROUP_ID=1000
# Create a group with same username to give ownership of group to this user for file perms
RUN groupadd -g ${GROUP_ID} ${USER_NAME} && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -G sudo -s /bin/bash -m ${USER_NAME} && \
    echo "${USER_NAME}:${USER_NAME}" | chpasswd

ENV HOMELAB_DIR=/workspace/homelab
WORKDIR ${HOMELAB_DIR}

# Make required directories and chown them
RUN mkdir ./roles /home/${USER_NAME}/.ssh /home/${USER_NAME}/.kube && \
# Also ensure sudo group users are not asked for a password when using sudo command
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Installs Ansible, pre-commit-hooks, molecule, along with other pip dependencies.
COPY --from=project --chown=${USER_NAME}:${USER_NAME} requirements.txt ${HOMELAB_DIR}/
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir -r ${HOMELAB_DIR}/requirements.txt

# Copy ansible requirements and install them
COPY --from=project --chown=${USER_NAME}:${USER_NAME} provision/ansible/requirements.yml ${HOMELAB_DIR}/
COPY --from=project --chown=${USER_NAME}:${USER_NAME} provision/ansible/roles/requirements.yml ${HOMELAB_DIR}/roles/

RUN mkdir -p /usr/share/ansible/collections && \
    mkdir -p /usr/share/ansible/roles && \
    ansible-galaxy collection install -r ./requirements.yml --collections-path /usr/share/ansible/collections && \
    ansible-galaxy role install -r ./roles/requirements.yml --roles-path /usr/share/ansible/roles

# Copy bin files and docker-entrypoint.sh
COPY --from=dockerdir assets/bin /usr/local/bin
COPY --from=dockerdir assets/docker-entrypoint.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
COPY --from=dockerdir assets/.bash_aliases /home/${USER_NAME}/.bash_aliases

# Some plays delegate to localhost, requires access to itself on ssh
EXPOSE 22

# Parse the password from ENV and give us shell as default so we can do whatever
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
