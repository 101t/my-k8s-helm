#!/bin/bash

: ${USE_SUDO:="true"}

# runs the given command as root (detects if we are root already)
runAsRoot() {
  if [ $EUID -ne 0 -a "$USE_SUDO" = "true" ]; then
    sudo "${@}"
  else
    "${@}"
  fi
}

# Prepare System
runAsRoot apt-get update && runAsRoot apt-get -y upgrade

# Install pre-required software
runAsRoot apt-get install -y gnupg software-properties-common wget curl git

# Install Terraform
if ! terraform -v > /dev/null 2>&1; then
    echo "Installing Terraform"
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

    runAsRoot apt-get update && runAsRoot apt-get install -y terraform
    echo "Terraform installed successfully!"
fi

# Install Helm
if ! helm version > /dev/null 2>&1; then
    echo "Installing Helm"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    # Add Helm to your PATH (optional)
    runAsRoot mv /usr/local/bin/helm /usr/bin/helm
    echo "Helm installed successfully!"
fi

# Install KubeCTL
if ! kubectl version --client > /dev/null 2>&1; then
    echo "Installing KubeCTL"
    # Download Binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    # Validate Binary
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    # Install Binary
    runAsRoot install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    echo "KubeCTL installed successfully!"
fi

# Install Kind
if ! kind --version > /dev/null 2>&1; then
    echo "Installing Kind"
    curl -fsSL -o ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
    chmod +x ./kind

    # Add Kind to PATH
    runAsRoot mv ./kind /usr/local/bin/kind
    echo "Kind installed successfully!"
fi

# Installing Redis-CLI
if ! redis-cli --version > /dev/null 2>&1; then
    echo "Installing Redis-Tools"
    runAsRoot apt-get update && runAsRoot apt-get install -y redis-tools
fi

# Installing psql
if ! psql --version > /dev/null 2>&1; then
    echo "Installing PSQL"
    runAsRoot apt-get update && runAsRoot apt-get install -y postgresql-client
fi

# Clean apt scripts
runAsRoot apt-get -y autoremove