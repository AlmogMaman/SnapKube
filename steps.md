Documentation covering: - System architecture. - V - Deployment
instructions. - V - Cleanup - V - User guide. - Steps - V

###Description: Web Screenshot Application on Kubernetes - On-premise.

\### Prerequisites:  - Docker up and running  - kubectl  - Rancher  -
Helm

\### How to run: Deployment instructions: run the
\'scripts/rancher-setup.bash\' (pay attention to Step 1 below) run the
\'scripts/cluster-setup.bash\'

\### Explain about the process:

\### Steps:

\# Step 1: Set up Rancher (in scripts folder) Set up on-prem k8s
cluster. Using Rancher. commands: (the is a script for set this up:
scripts/rancher-setup.bash) #!/bin/bash

\# Start Rancher server echo \"Starting Rancher server\...\" docker run
-d \--privileged \--restart=unless-stopped -p 80:80 -p 443:443
rancher/rancher

\# Wait for Rancher to start echo \"Waiting for Rancher to start\...\"
sleep 30

\# Access Rancher UI echo \"Access Rancher UI at https://localhost\"

\# Configure kubectl to use Rancher echo \"Configuring kubectl to use
Rancher\...\" RANCHER_URL=\"https://localhost\" kubectl config
set-cluster rancher-cluster \--server=\$RANCHER_URL
\--insecure-skip-tls-verify=true kubectl config set-context
rancher-context \--cluster=rancher-cluster kubectl config use-context
rancher-context

\# Copy kubeconfig file to \~/.kube/config manualy

\# Check the current kubectl context echo \"Current kubectl context:\"
kubectl config current-context

echo \"Rancher setup completed successfully!\"

#Pay atention that in the procees the rancher will ask for username and
password. we need to reach rancher via the rancher url - localhost:443 -
from there has a command to find the Bootstrap Password, and then there
is a password that we can choose. hit the password and agree to terms,
hit continue. now you have the password to the admini user.

####Adding here a picture

#Pay attention to copy the kubeconfig from the cluster (find via rancher
ui) to the \~/.kube/config file for setting the kubectl to work properly
on the cluster (rancher)

####Adding here a picture

\# Step2: Build the application, dockerize it and push it to the docker
hub, deploy it in the cluster. With these features:  - Accept user input
for a target website URL.  - Capture a screenshot of the specified
website.  - Store screenshot metadata and file references in a database.

\# Step 3: Set the ingress controller with TLS self signed Certificate.
Set up the application and the ingress controller. Now we have the
application running in the cluster accesible via ingress controller
(nginx)

#Set this in the host file in you os. \# To update the OS host file, add
the following line: \## 127.0.0.1 screenshot-app.local \# For Linux or
macOS, edit the /etc/hosts file: \# sudo nano /etc/hosts \# For Windows,
edit the C:\\Windows\\System32\\drivers\\etc\\hosts file: \# Notepad
should be run as Administrator to save changes.

#Adding a picture here

#Step 4: Set up postgressSql as my db. via stetful set.

\# Adding a picture here

#Step 5: Adjust the application working properly with the postgressSQL
db. #Adding pictures here of postgress working with the app.

UPCOMMING: CI/CD Monitoring Logging

\### Architecture in Local Kubernetes Cluster (Rancher):

\# Adding here the architecture file.

\### Cleanup: run \'scripts/cluster-cleanup.bash\' run
\'scripts/rancher-cleanup.bash\'

\# Web Screenshot Application Deployment Steps

\## 1. Infrastructure Setup

1.1. Install Prerequisites - Install Docker - Install kubectl - Install
minikube (for local development) - Install helm

1.2. Set up Kubernetes Cluster - Initialize master node - Configure
networking (Calico/Flannel) - Join worker nodes - Verify cluster status

\## 2. Application Development

2.1. Create Web Application - Set up Python Flask application -
Implement screenshot capture using Selenium/Playwright - Create REST API
endpoints - Build frontend interface

2.2. Database Setup - Deploy PostgreSQL database - Create schemas for:
 - Users  - Screenshots metadata  - File references

2.3. Application Testing - Unit tests - Integration tests - Load testing

\## 3. Containerization

3.1. Create Docker Images - Write Dockerfile for web application - Build
and test locally - Push to container registry

3.2. Database Container - Use official PostgreSQL image - Configure
persistence - Set up backup strategy

\## 4. Kubernetes Deployment

4.1. Create Kubernetes Manifests - Deployments - Services - ConfigMaps -
Secrets - PersistentVolumeClaims

4.2. Set up Ingress - Deploy NGINX Ingress Controller - Configure
routing rules - Set up TLS certificates using cert-manager

4.3. Resource Management - Set resource limits - Configure HPA
(Horizontal Pod Autoscaling) - Implement pod disruption budgets

\## 5. CI/CD Pipeline

5.1. Set up Pipeline (Jenkins/GitLab CI) - Source code management -
Automated testing - Image building - Deployment automation

5.2. Implement Security Scanning - Container vulnerability scanning -
Code security analysis - Dependency checking

\## 6. Monitoring and Logging

6.1. Monitoring Setup - Deploy Prometheus - Configure Grafana
dashboards - Set up alerting

6.2. Logging Solution - Deploy ELK Stack/Loki - Configure log
aggregation - Set up log retention policies

\## 7. Documentation

7.1. Technical Documentation - System architecture diagrams - Component
interactions - API documentation

7.2. Operational Documentation - Deployment procedures - Backup and
recovery - Troubleshooting guides

7.3. User Documentation - Installation guide - Usage instructions - FAQ

\## 8. Security Measures

8.1. Implementation - Network policies - RBAC configuration - Secret
management - Security context constraints

8.2. Regular Maintenance - Security patches - Certificate rotation -
Access review

\## Web Screenshot Application Architecture

Frontend ─► API Server ─► Screenshot Service ─► PostgreSQL DB │ ▼
Storage (PVC) │ ▼ Storage (PV)