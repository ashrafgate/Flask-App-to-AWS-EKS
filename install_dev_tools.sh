#!/bin/bash

set -e

echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing required dependencies..."
sudo apt install -y curl unzip git apt-transport-https ca-certificates gnupg lsb-release software-properties-common

### Install Jenkins ###
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y openjdk-17-jdk jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

### Install Terraform ###
echo "Installing Terraform..."
TERRAFORM_VERSION="1.8.4"
curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
unzip terraform.zip
sudo mv terraform /usr/local/bin/
rm terraform.zip

### Install Docker ###
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins

### Install kubectl ###
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

### Install eksctl ###
echo "Installing eksctl..."
curl -s --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz
sudo mv eksctl /usr/local/bin/

echo "All tools installed successfully."
echo "You may need to reboot or re-login for Docker group membership to apply."
