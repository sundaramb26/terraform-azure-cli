# Build arguments
ARG AZURE_CLI_VERSION
ARG TERRAFORM_VERSION
ARG PYTHON_MAJOR_VERSION=3.9
ARG DEBIAN_VERSION=bullseye-20210902-slim

# Download Terraform binary
FROM debian:${DEBIAN_VERSION} as terraform-cli
ARG TERRAFORM_VERSION
RUN apt-get update
# RUN apt-get install --no-install-recommends -y curl=7.74.0-1.3+deb11u1
RUN apt-get install --no-install-recommends -y curl=7.74.0-1.3+deb11u7
RUN apt-get install --no-install-recommends -y ca-certificates=20210119
# RUN apt-get install --no-install-recommends -y unzip=6.0-26
RUN apt-get install --no-install-recommends -y unzip
RUN apt-get install --no-install-recommends -y gnupg2
WORKDIR /workspace
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
COPY hashicorp.asc hashicorp.asc
RUN gpg --import hashicorp.asc
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install az CLI using PIP
FROM debian:${DEBIAN_VERSION} as azure-cli
ARG AZURE_CLI_VERSION
ARG PYTHON_MAJOR_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3=${PYTHON_MAJOR_VERSION}.2-3
RUN apt-get install -y --no-install-recommends python3-pip
RUN pip3 install --no-cache-dir setuptools==58.0.4
RUN pip3 install --no-cache-dir azure-cli==${AZURE_CLI_VERSION}

# Build final image
FROM debian:${DEBIAN_VERSION}
LABEL maintainer="sundaramb26@github"
ARG PYTHON_MAJOR_VERSION
# Check packages version with https://www.debian.org/distrib/packages
# updated Git version from  git=1:2.30.2-1 to 2.41.0 on 280623
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119 \
    git=2.41.0 \
    python3=${PYTHON_MAJOR_VERSION}.2-3 \
    python3-distutils=${PYTHON_MAJOR_VERSION}.2-1 \
    curl=7.74.0-1.3+deb11u7 \
    jq=1.6-2.1 \
    unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_MAJOR_VERSION} 1
WORKDIR /workspace
COPY --from=terraform-cli /workspace/terraform /usr/local/bin/terraform
COPY --from=azure-cli /usr/local/bin/az* /usr/local/bin/
COPY --from=azure-cli /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages
COPY --from=azure-cli /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages

CMD ["bash"]
