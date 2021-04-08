#!/bin/bash
#
# site specific stuff
#
. ~/proxy.rc
cluster=$(kubectl config current-context)
domain=k8s.org

#
# Which container image registry do we want to use
#
if [[ "${MY_REGISTRY}" == "" ]]
then 
  flag=""
else 
  flag="--set global.airgapped.repository=${MY_REGISTRY}/kasten-images"
  echo using registry ${MY_REGISTRY}/kasten-images
fi

#
# Which version of Kasten
#
if [[ "$1" == "latest" ]]
then
  version=""
else
  version="--version=3.0.11"
fi

#
# Check Syntax
#
if (( $# > 1 ))
then
  echo "usage: $0 [latest]"
  echo "  deploy Kasten version 2.5.25 unless latest is specified"
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
  echo Deploying Kasten, this will take a few minutes before all services are up and running
  helm install k10 kasten/k10 -n kasten-io --wait ${version} ${flag}
else
  echo helm chart k10 already installed
fi

#
# Wait for all services to become available, the --wait switch in the helm install command above should be enough
#   status of services can also be queried here: https://kasten.${cluster}.${domain}/k10/dashboardbff-svc/v0/k10HealthCheck
#

#
# deploy the S3 location which was created by the user.yml playbook
#
echo Deploying the S3 location
kubectl apply -f ~/.svtrancher/kasten-location.${cluster}.yml

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
  annotations:
    nginx.ingress.kubernetes.io/app-root: /k10/#
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

