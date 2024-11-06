helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager



helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}'



#see the deployments
kubectl get deploy -o name -n cert-manager | xargs -n1 -t kubectl rollout status -n cert-manager


#Create secret tls via cert manager.
kubectl create secret tls -n screenshots-project ca-key-pair --cert=ca.cert.pem --key=ca.key.pem













# helm install cert-manager jetstack/cert-manager \
#   --namespace cert-manager \
#   --version v1.13.3 \
#   --set installCRDs=true \
#   -f ../k8s/cert-manager/values.yaml
# kubectl apply -f ../k8s/cert-manager/letsencrypt-issuer.yaml

# # Check cert-manager pods
# kubectl get pods -n cert-manager

# # Check certificate status
# kubectl get certificate -A

# # Check certificate request status
# kubectl get certificaterequest -A

# # Check orders and challenges
# kubectl get order -A
# kubectl get challenge -A


# # helm uninstall cert-manager -n cert-manager
# # kubectl delete namespace cert-manager