#!/bin/bash

# Install dependencies
apt-get update
apt-get install -y apt-transport-https curl gnupg

# Add Kubernetes apt repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

# Install Minikube and kubectl
apt-get update
apt-get install -y minikube kubectl

# Start Minikube (using the private instance's IP as the control plane)
MINIKUBE_CONTROL_PLANE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)  #Get private IP
minikube start --driver=none --kubernetes-version=v1.27.3 --control-plane-ip $MINIKUBE_CONTROL_PLANE_IP --extra-config=kubelet.cgroupDriver=systemd --apiserver-ips=$MINIKUBE_CONTROL_PLANE_IP

# Configure kubectl to use Minikube context
eval $(minikube docker-env)
minikube config use minikube
kubectl config use-context minikube