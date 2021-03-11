#!/bin/bash
#
# site specific stuff
#
. ~/proxy.rc
cluster=$(kubectl config current-context)
domain=k8s.org
version="--version=2.5.25"

#
# Check Syntax
#
if (( $# != 0 ))
then
  echo "usage: $0"
  echo '  deploy Kasten'
  exit
fi

#
# Create the Namespace
#
kubectl get ns kasten-io >/dev/null 2>&1 || kubectl create ns kasten-io

#
# Deploy kasten
#
iamthere=$(helm ls -n k10  -f '^k10$' -q)
if [[ "$iamthere" != "k10" ]]
then
  helm repo add kasten https://charts.kasten.io/ >/dev/null 2>&1
  helm install k10 kasten/k10 -n kasten-io ${version}
else
  echo helm chart k10 already installed
fi

#
# Deploy the Ingress
#
manifest=$(mktemp)
cat <<EOF >${manifest}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kasten
  namespace: kasten-io
spec:
  rules:
  - host: kasten.${cluster}.${domain}
    http:
      paths:
      - backend:
          serviceName: gateway
          servicePort: 8000
        path: /
        pathType: Prefix
EOF
kubectl apply -f ${manifest}
unlink ${manifest}
kubectl get ingress kasten -n kasten-io
