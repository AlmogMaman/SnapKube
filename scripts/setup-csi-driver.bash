cd docs/csi
kubectl create configmap cloud-config --from-file=manifests/cpi-vsphere.conf --namespace=kube-system
kubectl create -f manifests/cpi-secret.conf
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl apply -f manifests/cloud-provider.yaml
kubectl create secret generic vsphere-config-secret --from-file=manifests/csi-vsphere.conf --namespace=kube-system
kubectl apply -f manifests/csi-driver-rbac.yaml
kubectl create -f manifests/csi-controller.yaml
kubectl apply -f manifests/csi-driver-ubuntu.yaml
kubectl apply -f manifests/storage-class.yaml