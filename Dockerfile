FROM ubuntu:18.04

ENV DOCKER_CE_VERSION=5:19.03.5~3-0~ubuntu-bionic
ENV KUBECTL_VERSION=v1.14.4
ENV TERRAFORM_VERSION=0.12.20
ENV KREW_VERSION=0.3.3
ENV PATH="/root/.krew/bin:/root/.local/bin:${PATH}"

# install Docker Engine - Comunity
# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" && \
   apt-get update && \
   apt-get install -y docker-ce=${DOCKER_CE_VERSION} docker-ce-cli=${DOCKER_CE_VERSION} containerd.io

# install awscli
# https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    apt-get install -y python3-distutils && \
    python3 get-pip.py --user && \
    pip3 install awscli --upgrade --user && \
    rm get-pip.py

# install kubectl

RUN curl --show-error --location https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl --output /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# install krew
# https://github.com/kubernetes-sigs/krew#installation
RUN TEMP_DIR=$(mktemp -d) && \
    cd ${TEMP_DIR} && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.3.3/krew.{tar.gz,yaml}" && \
    tar zxvf krew.tar.gz && \
    KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" && \
    "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz && \
    "$KREW" update && \
    rm ${TEMP_DIR}

# install kubectx, kubens
# https://github.com/ahmetb/kubectx#installation
RUN kubectl krew install ctx && \
    kubectl krew install ns

# install terraform
RUN apt-get install -y unzip && \
    curl -O --show-error --location  https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ && \
    rm terraform_0.12.20_linux_amd64.zip