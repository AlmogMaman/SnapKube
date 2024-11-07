kubectl delete -f ../k8s/secrets/
kubectl delete -f ../k8s/storage/
kubectl delete -f ../k8s/application/
kubectl delete -f ../k8s/postgres/
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system
kubectl delete secret screenshot-tls
helm install my-nginx ingress-nginx/ingress-nginx --namespace nginx

kubectl delete namespace screenshots-project
kubectl delete namespace nginx
