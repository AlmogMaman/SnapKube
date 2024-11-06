#!/bin/bash

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

# Copy kubeconfig file to ~/.kube/config
echo "Copying kubeconfig file to ~/.kube/config..."
cp /path/to/rancher/kubeconfig ~/.kube/config

# Check the current kubectl context
echo "Current kubectl context:"
kubectl config current-context

echo "Rancher setup completed successfully!"

#password: 42fvdrL5WOsEjjSl