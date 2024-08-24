# Stage 1: Base system and essential tools
FROM ubuntu:latest AS base

LABEL maintainer="Mohammad Abu Mattar <mohammad.khaled@outlook.com>"
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system packages
RUN apt-get update && apt-get -y dist-upgrade && \
  apt-get -y install --no-install-recommends \
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
  git \
  texlive-fonts-recommended \
  texlive-plain-generic \
  texlive-xetex \
  unzip \
  vim \
  nano \
  wget && \
  apt-get -y autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Set up locales
RUN locale-gen en_US.UTF-8 && update-locale

# Ensure bash is used and python3 is the default python
RUN ln -sf /bin/bash /bin/sh && ln -sf /usr/bin/python3 /usr/bin/python

# Install Node.js LTS version
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
  apt-get install -y nodejs && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# Stage 2: Install Python and pip
FROM base AS python

# Add Pip installation script
ADD https://bootstrap.pypa.io/get-pip.py /tmp/get-pip.py

# Install pip and Python packages in the virtual environment
RUN python3 /tmp/get-pip.py --break-system-packages && \
  pip install --no-cache-dir cython numpy pip --break-system-packages && \
  rm /tmp/get-pip.py

# Install requirements from the requirements.txt file
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt --break-system-packages && \
  rm -rf /tmp/requirements.txt

# Install TensorFlow
RUN pip install --no-cache-dir tensorflow --break-system-packages

# Stage 3: Install optional CLI tools
FROM python AS tools

ARG AWS_CLI=false
ARG AZURE_CLI=false
ARG GCP_CLI=false
ARG DOCKER_CLI=false
ARG TERRAFORM_CLI=false
ARG HELM_CLI=false
ARG KUBECTL_CLI=false
ARG ANSIBLE_CLI=false

ENV AWS_CLI=${AWS_CLI}
ENV AZURE_CLI=${AZURE_CLI}
ENV GCP_CLI=${GCP_CLI}
ENV DOCKER_CLI=${DOCKER_CLI}
ENV TERRAFORM_CLI=${TERRAFORM_CLI}
ENV HELM_CLI=${HELM_CLI}
ENV KUBECTL_CLI=${KUBECTL_CLI}
ENV ANSIBLE_CLI=${ANSIBLE_CLI}

# Install AWS CLI
RUN if [ "$AWS_CLI" = "true" ]; then \
  curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip aws; \
  fi

# Install Azure CLI
RUN if [ "$AZURE_CLI" = "true" ]; then \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
  fi

# Install GCP CLI
RUN if [ "$GCP_CLI" = "true" ]; then \
  apt-get update && apt-get install apt-transport-https ca-certificates gnupg -y && \
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
  apt-get update && apt-get install google-cloud-sdk -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

# Install Docker CLI
RUN if [ "$DOCKER_CLI" = "true" ]; then \
  apt-get update && \
  apt-get -y install apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common && \
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
  stable" && \
  apt-get update && \
  apt-get -y install docker-ce && \
  apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

# Install Terraform CLI
RUN if [ "$TERRAFORM_CLI" = "true" ]; then \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && apt-get install terraform -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

# Install Helm CLI
RUN if [ "$HELM_CLI" = "true" ]; then \
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
  chmod 700 get_helm.sh && \
  ./get_helm.sh && \
  rm get_helm.sh; \
  fi

# Install kubectl CLI
RUN if [ "$KUBECTL_CLI" = "true" ]; then \
  curl -fsSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.20.0/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl; \
  fi

# Install Ansible CLI
RUN if [ "$ANSIBLE_CLI" = "true" ]; then \
  apt-get update && \
  apt-get install -y software-properties-common && \
  apt-add-repository --yes --update ppa:ansible/ansible && \
  apt-get install -y ansible && \
  apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

# Stage 4: Final stage
FROM tools AS final

ENV HOME /home/notebook

# Create home directory and set permissions
RUN mkdir -p ${HOME} && \
  /usr/bin/python3 -m bash_kernel.install && \
  jt --theme oceans16 -f ubuntu --toolbar --nbname --vimext && \
  find ${HOME} -exec chmod 777 {} \;

# Expose port for Jupyter
EXPOSE 8888

# Set entrypoint for Jupyter
ENTRYPOINT ["/usr/local/bin/jupyter"]
