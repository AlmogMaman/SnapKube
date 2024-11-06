# Project Documentation

## System Architecture

The project is designed to manage user screenshots in a Kubernetes environment. It consists of several components:

- **Kubernetes Cluster**: The core of the deployment, managing containerized applications.
- **PostgreSQL Database**: Stores user screenshots and metadata.
- **Ingress Controller**: Manages external access to the services, providing load balancing and SSL termination.
- **Cert-Manager**: Automates the management and issuance of TLS certificates.
- **Metrics Server**: Collects resource metrics from Kubelets and exposes them to the Kubernetes API.

## Deployment Instructions

1. **Set Up Kubernetes Namespace**:
   ```bash
   kubectl create namespace screenshots-project
   kubectl config set-context --current --namespace=screenshots-project
   ```

2. **Apply Kubernetes Resources**:
   ```bash
   kubectl apply -f ../k8s/secrets/
   kubectl apply -f ../k8s/storage/
   kubectl apply -f ../k8s/application/
   kubectl apply -f ../k8s/postgres/
   ```

3. **Install Metrics Server**:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system
   ```

4. **Install NGINX Ingress Controller**:
   ```bash
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm repo update
   kubectl create ns nginx
   helm install my-nginx ingress-nginx/ingress-nginx --namespace nginx
   ```

5. **Set Up TLS Certificates**:
   ```bash
   openssl genrsa -out tls.key 2048
   openssl req -x509 -new -nodes -key tls.key -subj "/CN=screenshot-app.local" -days 365 -out tls.crt
   kubectl create secret tls screenshot-tls --cert=tls.crt --key=tls.key
   ```

6. **Configure Ingress**:
   Ensure that the ingress resource is properly configured to use the created TLS secret and routes traffic to the application.

## User Guide

1. **Accessing the Application**:
   After deployment, the application can be accessed via the configured domain (e.g., `https://screenshot-app.local`).

2. **Using the Application**:
   Users can upload screenshots, which will be stored in the PostgreSQL database. The application provides a user-friendly interface for managing and viewing screenshots.

3. **Monitoring**:
   Use the metrics server to monitor the health and performance of the application. Access metrics via:
   ```bash
   kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/screenshots-project/pods" | jq .
   ```

4. **Cleanup**:
   To clean up resources, use the provided cleanup scripts to remove deployments and configurations.
