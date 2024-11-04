#!/bin/bash

# Step 1: Set up on-prem k8s cluster using Minikube

# Start Minikube
echo "Starting Minikube..."
minikube start

# Check Minikube status
echo "Checking Minikube status..."
minikube status

# Enable Ingress addon
echo "Enabling Ingress addon..."
minikube addons enable ingress

# Open Minikube dashboard
echo "Opening Minikube dashboard..."
minikube dashboard &

# Change kubectl context to Minikube
echo "Changing kubectl context to Minikube..."
kubectl config get-contexts
kubectl config use-context minikube
kubectl config current-context

# Check the nodes
echo "Checking the nodes..."
kubectl get nodes

echo "Minikube setup completed successfully!"