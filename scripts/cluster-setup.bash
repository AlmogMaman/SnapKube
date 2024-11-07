#!/bin/bash


#Set a namespace for the project
kubectl create ns nginx
kubectl create namespace screenshots-project
kubectl config set-context --current --namespace=screenshots-project

#Verify the namespace:
kubectl config view --minify | grep namespace:


kubectl apply -f ../k8s/secrets/
kubectl apply -f ../k8s/storage/
kubectl apply -f ../k8s/application/
kubectl apply -f ../k8s/postgres/


#Install the controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-nginx ingress-nginx/ingress-nginx --namespace nginx


#For the metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system

#Verify the matrec server is working
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/screenshots-project/pods" | jq .


#Verify:
kubectl get pods -n kube-system | grep metrics-server
kubectl get apiservice | grep metrics

#Tls:
# Generate the private key
openssl genrsa -out tls.key 2048

# Generate the self-signed certificate
openssl req -x509 -new -nodes -key tls.key -subj "/CN=screenshot-app.local" -days 365 -out tls.crt


kubectl create secret tls screenshot-tls --cert=tls.crt --key=tls.key


kubectl get ingress screenshot-app

kubectl get svc


kubectl exec -it postgres-0 -- psql -U postgres -d screenshots -f /docker-entrypoint-initdb.d/init.sql



# Get the name of the Ingress service dynamically
INGRESS_SERVICE_NAME=$(kubectl get svc -n nginx -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')

# Check if the service name was found
if [ -z "$INGRESS_SERVICE_NAME" ]; then
    echo "No Ingress service found in the 'nginx' namespace."
    exit 1
fi

# Port forward to the Ingress service
kubectl port-forward -n nginx svc/$INGRESS_SERVICE_NAME 4430:443



