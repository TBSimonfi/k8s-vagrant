#!/bin/bash
#
# Setup for GitHub Runner server

set -euxo pipefail

<<<<<<< HEAD
GITHUB_ORG="TBSimonfi"      # GitHub organization or username
GITHUB_REPO="k8s-vagrant"   # GitHub repository name
GITHUB_PAT="y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" # GitHub personal access token
RUNNER_DIR="/home/vagrant/actions-runner"

# Create the runner directory if it doesn't exist
mkdir -p $RUNNER_DIR
cd $RUNNER_DIR

# Function to fetch a new runner token
get_runner_token() {
  echo "Fetching new runner token..."
  RUNNER_TOKEN=$(curl -sX POST -H "Authorization: token $GITHUB_PAT" \
    https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/actions/runners/registration-token \
    | jq -r '.token')
  echo "New runner token fetched."
}

# Fetch the initial runner token
get_runner_token

# Download the latest runner package if it doesn't exist
if [ ! -f actions-runner-linux-x64-2.322.0.tar.gz ]; then
  curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
  tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz
  chown -R vagrant:vagrant $RUNNER_DIR
fi

# Configure and install the runner
sudo -u vagrant ./config.sh --unattended --replace --url https://github.com/$GITHUB_ORG/$GITHUB_REPO --token $RUNNER_TOKEN
sudo ./svc.sh install vagrant
sudo ./svc.sh start

# Install ArgoCD CLI
=======
#
# Install Runner
#

# Create a folder
# mkdir actions-runner 
cd actions-runner
# Download the latest runner package
curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
# Extract the installer
tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz
chown -R vagrant:vagrant /home/vagrant/actions-runner 

#
# Configure Runner
#

# Create the runner and start the configuration experience
sudo -u vagrant ./config.sh --unattended --replace --url https://github.com/TBSimonfi/kube_cluster --token AJRTUPQANMUPTCWKBVIKPJLHY5Z7A
# Last step, install service and start it
sudo ./svc.sh install vagrant
sudo ./svc.sh start

#
# Install ArgoCD CLI
#
>>>>>>> ed4c9453b92826714790fcda7244f43df9ec552f
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

<<<<<<< HEAD
# Setup K8s config on server
config_path="/vagrant/configs"
sudo -i -u vagrant bash << EOF
=======
#
# Setup K8s config on server
#

config_path="/vagrant/configs"
sudo -i -u vagrant bash << EOF
whoami
>>>>>>> ed4c9453b92826714790fcda7244f43df9ec552f
mkdir -p /home/vagrant/.kube
sudo cp -i $config_path/config /home/vagrant/.kube/
sudo chown 1000:1000 /home/vagrant/.kube/config
EOF
<<<<<<< HEAD

# Schedule token refresh and runner re-registration every hour
while true; do
  sleep 3600  # Wait for an hour
  get_runner_token
  sudo -u vagrant ./config.sh --unattended --replace --url https://github.com/$GITHUB_ORG/$GITHUB_REPO --token $RUNNER_TOKEN
  sudo ./svc.sh restart
done
=======
>>>>>>> ed4c9453b92826714790fcda7244f43df9ec552f
