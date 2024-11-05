kubectl apply -f ../secrets/
kubectl apply -f ../storage/
kubectl apply -f ../application/

#For the metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --namespace=kube-system


kubectl -n kube-system patch deployment metrics-server --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"},
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-preferred-address-types=InternalIP"}
]'

#Verify the matrec server is working
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/screenshot-project/pods" | jq .


#Verify:
kubectl get pods -n kube-system | grep metrics-server
kubectl get apiservice | grep metrics

