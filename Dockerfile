FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

ADD https://bootstrap.pypa.io/get-pip.py /tmp/get-pip.py

RUN set -e \
  && ln -sf bash /bin/sh \
  && ln -s python3 /usr/bin/python

RUN set -e \
  && apt-get -y update \
  && apt-get -y dist-upgrade \
  && apt-get -y install --no-install-recommends --no-install-suggests \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  g++ \
  gcc \
  locales \
  p7zip-full \
  pandoc \
  pbzip2 \
  pigz \
  python3-dev \
  python3-distutils \
  git \
  texlive-fonts-recommended \
  texlive-plain-generic \
  texlive-xetex \
  unzip \
  vim \
  nano \
  wget \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

RUN apt-get update \
  && apt-get install -y nodejs

RUN set -e \
  && locale-gen en_US.UTF-8 \
  && update-locale

RUN set -e \
  && /usr/bin/python3 /tmp/get-pip.py \
  && pip install -U --no-cache-dir cython numpy pip

COPY requirements.txt /tmp/requirements.txt

RUN set -e \
  && pip install -U --no-cache-dir -r /tmp/requirements.txt \
  && rm -rf /tmp/requirements.txt

RUN set -e \
  && /usr/bin/python3 /tmp/get-pip.py \
  && pip install -U --no-cache-dir tensorflow

ARG AWS_CLI=false
ENV AWS_CLI=${AWS_CLI}

RUN if [ "$AWS_CLI" = "true" ]; then \
  curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  ;fi

ARG AZURE_CLI=false
ENV AZURE_CLI=${AZURE_CLI}

RUN if [ "$AZURE_CLI" = "true" ]; then \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
  ;fi

ARG GCP_CLI=false
ENV GCP_CLI=${GCP_CLI}

RUN if [ "$GCP_CLI" = "true" ]; then \
  apt-get install apt-transport-https ca-certificates gnupg -y \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && apt-get update \
  && apt-get install google-cloud-sdk -y \
  && apt-get install google-cloud-sdk-app-engine-python -y \
  ;fi

ARG DOCKER_CLI=false
ENV DOCKER_CLI=${DOCKER_CLI}

RUN if [ "$DOCKER_CLI" = "true" ]; then \
  apt-get update && \
  apt-get -y install apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common && \
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
  stable" && \
  apt-get update && \
  apt-get -y install docker-ce \
  ;fi

ARG TERRAFORM_CLI=false
ENV TERRAFORM_CLI=${TERRAFORM_CLI}

RUN if [ "$TERRAFORM_CLI" = "true" ]; then \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
  && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && apt-get update && apt-get install terraform \
  ;fi

ARG HELM_CLI=false
ENV HELM_CLI=${HELM_CLI}

RUN if [ "$HELM_CLI" = "true" ]; then \
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod 700 get_helm.sh \
  && ./get_helm.sh \
  ;fi

ARG KUBECTL_CLI=false
ENV KUBECTL_CLI=${KUBECTL_CLI}

RUN if [ "$KUBECTL_CLI" = "true" ]; then \
  curl -fsSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  ;fi

ARG ANSIBLE_CLI=false
ENV ANSIBLE_CLI=${ANSIBLE_CLI}

RUN if [ "$ANSIBLE_CLI" = "true" ]; then \
  apt-get update \
  && apt-get install -y software-properties-common \
  && apt-add-repository --yes --update ppa:ansible/ansible \
  && apt-get install -y ansible \
  ;fi

ENV HOME /home/notebook

RUN set -e \
  && mkdir ${HOME} \
  && /usr/bin/python3 -m bash_kernel.install \
  && jt --theme oceans16 -f ubuntu --toolbar --nbname --vimext \
  && find ${HOME} -exec chmod 777 {} \; 

EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/jupyter"]