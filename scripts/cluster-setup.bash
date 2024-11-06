kubectl apply -f ../k8s/secrets/
kubectl apply -f ../k8s/storage/
kubectl apply -f ../k8s/application/
kubectl apply -f ../k8s/postgres/

#For the metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system


# kubectl -n kube-system patch deployment metrics-server --type='json' -p='[
#   {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
#   {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}
# ]'

#Verify the matrec server is working
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/screenshots-project/pods" | jq .


#Verify:
kubectl get pods -n kube-system | grep metrics-server
kubectl get apiservice | grep metrics

#Hnadeling the ingress controller and the TLS certification:



#Install the controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
kubectl create ns nginx

#helm update my-nginx ingress-nginx/ingress-nginx --namespace nginx
helm install my-nginx ingress-nginx/ingress-nginx --namespace nginx


# helm install my-nginx ingress-nginx/ingress-nginx \
#   --namespace nginx \
#   --set controller.service.type=NodePort \
#   --set controller.service.nodePorts.http=30000 \
#   --set controller.service.nodePorts.https=30001



#Tls
# Generate the private key
openssl genrsa -out tls.key 2048

# Generate the self-signed certificate
openssl req -x509 -new -nodes -key tls.key -subj "/CN=screenshot-app.local" -days 365 -out tls.crt

# openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
# -keyout screenshot-key.pem -out screenshot-cert.pem \
# -subj "/CN=screenshot-app.local/O=MyOrg"


kubectl create secret tls screenshot-tls --cert=tls.crt --key=tls.key

# kubectl create secret tls screenshot-tls --cert=screenshot-cert.pem --key=screenshot-key.pem

#Set this in the host file in you os.
#127.0.0.1 screenshot-app.local

kubectl get ingress screenshot-app

# kubectl port-forward -n nginx svc/my-nginx-ingress-nginx-controller  4430:443
kubectl port-forward -n nginx svc/my-nginx-ingress-nginx-controller 0.0.0.0:4430:443

kubectl get svc




#Set up DNS record - localy to the ingress host,

