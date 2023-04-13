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

ARG AWS_CLI=false
ARG AZURE_CLI=false
ARG GCP_CLI=false

ENV AWS_CLI=${AWS_CLI}
ENV AZURE_CLI=${AZURE_CLI}
ENV GCP_CLI=${GCP_CLI}

RUN if [ "$AWS_CLI" = "true" ]; then \
  curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  ;fi

RUN if [ "$AZURE_CLI" = "true" ]; then \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
  ;fi

RUN if [ "$GCP_CLI" = "true" ]; then \
  apt-get install apt-transport-https ca-certificates gnupg -y \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && apt-get update \
  && apt-get install google-cloud-sdk -y \
  && apt-get install google-cloud-sdk-app-engine-python -y \
  ;fi

ENV HOME /home/notebook

RUN set -e \
  && mkdir ${HOME} \
  && /usr/bin/python3 -m bash_kernel.install \
  && jupyter contrib nbextension install --system \
  && jt --theme oceans16 -f ubuntu --toolbar --nbname --vimext \
  && find ${HOME} -exec chmod 777 {} \; \
  && jupyter nbextension enable --py widgetsnbextension

EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/jupyter"]