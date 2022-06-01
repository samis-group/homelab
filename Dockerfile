FROM python:3
# I pass VAULT_PASS in through build-args, and it's available at container build in env at my git repo as well for build ci/cd pipeline.

# ARG = only available at docker build, not in container
# Also, you need to declare it in your dockerfile to use it in the makes
ARG VAULT_PASS
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Sydney

# Ensure apt runs non-interactively due to tzdata package asking for location, argh..
RUN mkdir -p /root/.ssh /root/ansible

RUN apt-get update \
  && apt-get install -y tzdata make vim openssh-server \
  && service ssh start \
  && pip3 install --upgrade pip

WORKDIR /root/ansible

# Copy root of repo in container
COPY . .
RUN ./bin/parse_pass.py

RUN pip3 install --no-cache-dir -r requirements.txt

# Ansible requirements - galaxy issues right now?
RUN make reqs

# Allow bind mount keys from outside container
VOLUME [ "/root/.ssh" ]

# # Expose SSH port
# EXPOSE 22

# Give us shell as default so we can do whatever
CMD [ "/bin/bash" ]