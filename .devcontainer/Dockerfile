FROM ghcr.io/ansible/community-ansible-dev-tools:v26.1.0

COPY requirements.yaml /tmp/requirements.yaml

# https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
RUN pip install --upgrade ansible-core && \
    ansible-galaxy install -r /tmp/requirements.yaml && \
    dnf install -y 'dnf5-command(config-manager)' && \
    dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && \
    dnf install -y python3-passlib packer unzip terraform && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    packer plugins install github.com/hashicorp/amazon 1.6.0 && \
    packer plugins install github.com/hashicorp/ansible 1.1.4

RUN pip install 'pywinrm>=0.4.0' 'pypsrp<=1.0.0' 'requests_credssp'
RUN ansible-galaxy install -r /tmp/requirements.yaml
