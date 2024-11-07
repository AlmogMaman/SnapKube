# Start Generation Here
# Web Screenshot Application on Kubernetes - On-premise

## Description
This project provides a web screenshot application that runs on a Kubernetes cluster using Rancher. It allows users to capture screenshots of specified websites and store the metadata and file references in a PostgreSQL database.

## Prerequisites
- Docker must be installed and running.
- kubectl must be installed.
- Rancher must be set up.
- Helm must be installed.

## How to Run
1. Run the Rancher setup script:
   ```bash
   ./scripts/rancher-setup.bash
   ```
   Follow the instructions to set up Rancher and configure kubectl.

2. Run the cluster setup script:
   ```bash
   ./scripts/cluster-setup.bash
   ```

## Steps
### Step 1: Set up Rancher
- Start the Rancher server using Docker.
- Access the Rancher UI at `https://localhost`.
- Configure kubectl to use Rancher.

### Step 2: Build the Application
- Dockerize the application and push it to Docker Hub.
- Implement features to accept user input for a target website URL, capture screenshots, and store metadata in a database.

### Step 3: Set up Ingress Controller
- Configure the ingress controller with a self-signed TLS certificate.
- Ensure the application is accessible via the ingress controller.

### Step 4: Set up PostgreSQL
- Deploy PostgreSQL as a StatefulSet in the cluster.

### Step 5: Application Integration
- Adjust the application to work with the PostgreSQL database.

## Upcoming Features
- CI/CD integration
- Monitoring and logging capabilities

## Cleanup
To clean up the resources, run the following scripts:

