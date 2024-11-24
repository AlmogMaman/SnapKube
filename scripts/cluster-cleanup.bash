# kubectl delete -f ../k8s/secrets/
# kubectl delete -f ../k8s/storage/
# kubectl delete -f ../k8s/application/
# kubectl delete -f ../k8s/postgres/
# kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system
# kubectl delete secret screenshot-tls
# helm uninstall my-nginx ingress-nginx/ingress-nginx --namespace nginx



#!/bin/bash

# Delete Argo CD resources first
echo "Cleaning up Argo CD resources..."
kubectl delete -f ../k8s/argocd/ || true
kubectl delete namespace argocd || true

# Delete application resources
echo "Cleaning up application resources..."
kubectl delete -f ../k8s/secrets/ || true
kubectl delete -f ../k8s/storage/ || true
kubectl delete -f ../k8s/application/ || true
kubectl delete -f ../k8s/postgres/ || true

# Delete other resources
echo "Cleaning up other resources..."
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system || true
kubectl delete secret screenshot-tls || true
helm uninstall my-nginx ingress-nginx/ingress-nginx --namespace nginx || true

# Delete namespaces
echo "Cleaning up namespaces..."
kubectl delete namespace screenshots-project
kubectl delete namespace nginx
