# SnapKube

A Kubernetes-based web application that captures and stores website screenshots with automated deployment and scaling capabilities.

![SnapKube Architecture](docs/images/architecture.png)

## 🚀 Features

- Website screenshot capture via REST API
- Automated Kubernetes deployment
- PostgreSQL database for metadata storage
- Secure TLS communication
- Prometheus monitoring integration
- Automated CI/CD with GitHub Actions
- Horizontal pod autoscaling

## 🏗️ Quick Start

### Prerequisites

- Kubernetes cluster (or minikube for local development)
- kubectl
- Docker
- Helm
- Python 3.9+

### Local Development

```bash
# Clone repository
git clone https://github.com/yourusername/snapkube.git