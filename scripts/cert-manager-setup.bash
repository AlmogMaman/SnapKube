helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.13.3 \
  --set installCRDs=true \
  -f ../k8s/cert-manager/values.yaml

kubectl apply -f ../k8s/cert-manager/letsencrypt-issuer.yaml

# Check cert-manager pods
kubectl get pods -n cert-manager

# Check certificate status
kubectl get certificate -A

# Check certificate request status
kubectl get certificaterequest -A

# Check orders and challenges
kubectl get order -A
kubectl get challenge -A


# helm uninstall cert-manager -n cert-manager
# kubectl delete namespace cert-manager