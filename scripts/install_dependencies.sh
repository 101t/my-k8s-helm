#!/bin/bash


sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove
sudo apt-get install -y gnupg software-properties-common wget curl

# Install Terraform
echo "Installing Terraform"

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install terraform

# Install Helm
echo "Installing Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

# Add Helm to your PATH (optional)
sudo mv /usr/local/bin/helm /usr/bin/helm

echo "Terraform and Helm installed successfully!"
