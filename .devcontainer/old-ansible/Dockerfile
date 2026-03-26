FROM ubuntu:20.04

ARG ARCH=arm64

COPY requirements.yaml /tmp/requirements.yaml

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y python3.9 python3-pip ansible ansible-lint python3-passlib unzip git && \
    pip install --upgrade ansible-core 'bcrypt<5' && \
    ansible-galaxy collection install -r /tmp/requirements.yaml

# https://developer.hashicorp.com/packer/install
ADD https://releases.hashicorp.com/packer/1.14.2/packer_1.14.2_linux_${ARCH}.zip packer.zip

RUN unzip packer.zip && \
    mv packer /usr/local/bin/ && \
    packer plugins install github.com/hashicorp/amazon 1.6.0  && \
    packer plugins install github.com/hashicorp/ansible 1.1.4
