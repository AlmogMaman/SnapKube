#!/bin/bash

# Set up namespaces
kubectl create ns nginx
kubectl create namespace screenshots-project
kubectl config set-context --current --namespace=screenshots-project

# Verify the namespace:
kubectl config view --minify | grep namespace:

# Install the ingress controller first
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-nginx ingress-nginx/ingress-nginx --namespace nginx

# Apply base infrastructure
kubectl apply -f ../k8s/secrets/
kubectl apply -f ../k8s/storage/
kubectl apply -f ../k8s/postgres/

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s

# Get latest image digest
echo "Fetching latest image digest..."
LATEST_DIGEST=$(curl -s -H "Authorization: Bearer $DOCKER_TOKEN" "https://hub.docker.com/v2/repositories/almogmaman762/screenshot-app/tags" | grep -o '"digest":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -n "$LATEST_DIGEST" ]; then
    echo "Found latest digest: $LATEST_DIGEST"
    # Update deployment.yaml with latest digest
    sed -i "s|@sha256:latest-digest|@$LATEST_DIGEST|" ../k8s/application/deployment.yaml
    # Apply the deployment with latest image
    kubectl apply -f ../k8s/application/
else
    echo "Failed to fetch latest digest. Please check your Docker Hub credentials."
    exit 1
fi

# Execute init.sql
kubectl exec -it postgres-0 -- psql -U postgres -d screenshots -f /docker-entrypoint-initdb.d/init.sql

# For the metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system

# Verify the metrics server is working
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/screenshots-project/pods" | jq .

# Verify metrics server:
kubectl get pods -n kube-system | grep metrics-server
kubectl get apiservice | grep metrics

# TLS Setup:
# Generate the private key
openssl genrsa -out tls.key 2048

# Generate the self-signed certificate
openssl req -x509 -new -nodes -key tls.key -subj "/CN=screenshot-app.local" -days 365 -out tls.crt

kubectl create secret tls screenshot-tls --cert=tls.crt --key=tls.key

# Now set up Argo CD
echo "Setting up Argo CD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Wait for Argo CD to be ready
echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s

# Create Docker Hub secret for image updater
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_TOKEN" ]; then
    echo "Please set DOCKER_USERNAME and DOCKER_TOKEN environment variables"
    exit 1
fi

kubectl create secret generic dockerhub-secret \
    --namespace argocd \
    --from-literal=username=$DOCKER_USERNAME \
    --from-literal=password=$DOCKER_TOKEN

# Apply Argo CD application configuration
kubectl apply -f ../k8s/argocd/

# Copy TLS secret to argocd namespace
kubectl get secret screenshot-tls -o yaml | sed 's/namespace: .*/namespace: argocd/' | kubectl apply -f -

echo "Setting up ArgoCD ingress..."
kubectl apply -f ../k8s/argocd/ingress.yaml

# Get the name of the Ingress service dynamically
INGRESS_SERVICE_NAME=$(kubectl get svc -n nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
if [ -n "$INGRESS_SERVICE_NAME" ]; then
    echo "Setting up port forwarding for ingress on port 4430..."
    kubectl port-forward -n nginx svc/$INGRESS_SERVICE_NAME 4430:443 &
    
    echo "Services are accessible at:"
    echo "- Screenshot app: https://screenshot-app.local:4430/app"
    echo "- ArgoCD: https://screenshot-app.local:4430/argocd"
    echo "ArgoCD initial admin password:"
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    echo
else
    echo "Warning: Ingress service not found"
fi

# Display final status
echo "Checking deployment status..."
kubectl get pods -n argocd
kubectl get ingress screenshot-app
kubectl get svc

kubectl exec -it postgres-0 -- psql -U postgres -d screenshots -f /docker-entrypoint-initdb.d/init.sql
