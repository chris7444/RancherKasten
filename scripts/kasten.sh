. ~/proxy.rc
kubectl get ns kasten-io >/dev/null 2>&1 || kubectl create ns kasten-io
helm repo add kasten https://charts.kasten.io/
helm install k10 kasten/k10 --namespace=kasten-io --version=2.5.25
kubectl --namespace kasten-io get pod
echo kubectl --namespace kasten-io port-forward service/gateway 8080:8000
echo browse to http://127.0.0.1:8080/k10/#/

