#!/bin/bash

# Update package repositories
apt-get update -y

# Install dependencies
apt-get install -y curl wget apt-transport-https

# Add Kubernetes apt repository (CORRECTED)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Update package repositories AGAIN after adding the Kubernetes repo
install minikube-linux-amd64 /usr/local/bin/minikube

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# Install Minikube and kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# Get private IP
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Start Minikube
minikube start --driver=none --kubernetes-version=v1.27.3 --control-plane-ip $PRIVATE_IP --extra-config=kubelet.cgroupDriver=systemd --apiserver-ips=$PRIVATE_IP

# Configure kubectl
eval $(minikube docker-env)
minikube config use minikube
kubectl config use-context minikube