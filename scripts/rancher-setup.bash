#!/bin/bash

# Step 1: Set up on-prem k8s cluster using Rancher

# Start Rancher server
echo "Starting Rancher server..."
docker run -d --privileged --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher

# Wait for Rancher to start
echo "Waiting for Rancher to start..."
sleep 30

# Access Rancher UI
echo "Access Rancher UI at https://localhost"

# Configure kubectl to use Rancher
echo "Configuring kubectl to use Rancher..."
RANCHER_URL="https://localhost"
kubectl config set-cluster rancher-cluster --server=$RANCHER_URL --insecure-skip-tls-verify=true
kubectl config set-context rancher-context --cluster=rancher-cluster
kubectl config use-context rancher-context

# Check the nodes
echo "Checking the nodes..."
kubectl get nodes

# Check the current kubectl context
echo "Current kubectl context:"
kubectl config current-context

# Enable Ingress in Rancher
# echo "Enabling Ingress in Rancher..."
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

#Set a namespace for the project
kubectl create namespace screenshots-project
kubectl config set-context --current --namespace=screenshots-project

#Verify the namespace:
kubectl config view --minify | grep namespace:



echo "Rancher setup completed successfully!"

#password: DOEBJetsg9VrTdLW