#!/bin/bash
#
# Setup for GitHub Runner server

set -euxo pipefail

# Variables
REPO_URL="https://github.com/TBSimonfi/k8s-vagrant"
API_URL="https://api.github.com/repos/TBSimonfi/k8s-vagrant"
GITHUB_TOKEN="y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"
RUNNER_NAME="self-hosted-k8s-runner"
RUNNER_LABELS="self-hosted,Linux,K8s"
RUNNER_DIR="/home/vagrant/actions-runner"

# Install dependencies
sudo apt-get install -y curl jq

#
# Install Runner
#

# Check if the runner directory exists
if [ ! -d "$RUNNER_DIR" ]; then
  mkdir -p $RUNNER_DIR
fi

cd $RUNNER_DIR

# Download the latest runner package if it doesn't exist
if [ ! -f actions-runner-linux-x64-2.322.0.tar.gz ]; then
  curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
  tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz
  chown -R vagrant:vagrant $RUNNER_DIR
  rm -f ./actions-runner-linux-x64-2.322.0.tar.gz
fi

# Get the runner token from GitHub
RUNNER_TOKEN=$(curl -X POST -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" "$API_URL/actions/runners/registration-token" | jq -e -r .token)

#
# Configure Runner
#

# Create the runner and start the configuration experience
sudo -u vagrant ./config.sh --unattended --replace --url $REPO_URL --token $RUNNER_TOKEN --name $RUNNER_NAME --labels $RUNNER_LABELS

# Last step, install service and start it
sudo ./svc.sh install vagrant
sudo ./svc.sh start

#
# Install kubectl
#
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

#
# Install ArgoCD CLI
#
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

#
# Setup K8s config on server
#

config_path="/vagrant/configs"
sudo -i -u vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
EOF
