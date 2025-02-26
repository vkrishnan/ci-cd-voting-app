#!/bin/bash

# Install Docker (example)
sudo apt-get update
sudo apt-get install -y docker.io

# Add user to docker group (so you don't need sudo for docker commands)
sudo usermod -aG docker ubuntu  # Replace 'ubuntu' with your username if different
newgrp docker # Apply the group change without logout/login

# Install Minikube (example - adjust version as needed)
curl -LO "https://storage.googleapis.com/minikube/releases/v1.28.0/minikube_linux-amd64"
sudo install minikube_linux-amd64 /usr/local/bin/minikube

# Start Minikube (configure driver and advertise address if needed)
minikube start --driver=none --advertise-address=${private_ip_1} --listen-address=${private_ip_1} --extra-config=kubelet.networkPlugin=cni  &
minikube start --driver=none --advertise-address=${private_ip_2} --listen-address=${private_ip_2} --extra-config=kubelet.networkPlugin=cni  &

#Install kubectl
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.28.0/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl