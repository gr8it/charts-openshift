FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG KUBECTL_VERSION="1.28.0"
ARG YQ_VERSION="v4.44.3"
ARG UNITTEST_VERSION="1.0.3"
ARG HELM_VERSION="3.16.3"
ARG TARGETARCH

# Install base dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Detect architecture and set variables
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        echo "amd64" > /tmp/arch; \
    elif [[ "$(uname -m)" = "aarch64" || "$(uname -m)" = "arm64" ]]; then \
        echo "arm64" > /tmp/arch; \
    else \
        echo "Unsupported architecture: $(uname -m)"; exit 1; \
    fi

# Install kubectl
RUN ARCH=$(cat /tmp/arch) \
    && curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Install helm
RUN ARCH=$(cat /tmp/arch) \
    && wget -q "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" \
    && tar -zxf "helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" \
    && mv linux-${ARCH}/helm /usr/local/bin/helm \
    && rm -rf linux-${ARCH} "helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" \
    && chmod +x /usr/local/bin/helm

# Install yq v4 (mikefarah)
RUN ARCH=$(cat /tmp/arch) \
    && YQ_BINARY="yq_linux_${ARCH}" \
    && wget -q "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}" -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && rm /tmp/arch

# Install helm unittest plugin as vscode user
USER vscode
RUN helm plugin install https://github.com/helm-unittest/helm-unittest.git --version "${UNITTEST_VERSION}"

# Switch back to root for any additional setup
USER root
