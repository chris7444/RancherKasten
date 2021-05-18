#!/bin/bash
#
# Deploy the Kubernetes Dashboard
#

#
# site specific stuff
#
. ~/proxy.rc
cluster=$(kubectl config current-context)
domain=${MY_DOMAIN:-hpe.org}

#
# Which container image registry do we want to use
#
if [[ "${MY_REGISTRY}" == "" ]]
then 
  flag=""
else 
  flag="--set image.repository=${MY_REGISTRY}/kubernetesui/dashboard"
  echo using registry ${MY_REGISTRY}/kubernetesui/dashboard
fi

#
# Which version of the Dashboard
#
if [[ "$1" == "latest" ]]
then
  version=""
else
  version="--version=4.0.2"
fi

#
# Check Syntax
#
if (( $# > 1 ))
then
  echo "usage: $0 [latest]"
  echo "  deploy the Kubernetes Dashboard version x.y.z unless 'latest' is specified"
  exit
fi

#
# Create the Namespace
#
namespace=kubernetes-dashboard
kubectl get ns ${namespace} >/dev/null 2>&1 || kubectl create ns ${namespace}

#
# Deploy The Dashboard
#
iamthere=$(helm ls -n ${namespace} -f '^k8s-dashboard$' -q)
if [[ "$iamthere" != "k8s-dashboard" ]]
then
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ >/dev/null 2>&1
  echo Deploying the Kubernetes Dashboard, this will take a few minutes before all services are up and running
  helm install k8s-dashboard kubernetes-dashboard/kubernetes-dashboard -n ${namespace} --wait ${version} ${flag}
else
  echo helm chart k8s-dashboard already installed in namespace ${namespace}
fi

#
# Deploy the Ingress
#
manifest=$(mktemp)
cat <<EOF >${manifest}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
  name: dashboard
  namespace: ${namespace}
spec:
  rules:
  - host: dashboard.${cluster}.${domain}
    http:
      paths:
      - backend:
          service:
            # the name of the service depends on the name chose for the helm release
            name: k8s-dashboard-kubernetes-dashboard
            port:
              number: 443
        path: /
        pathType: Prefix
EOF
kubectl apply -f ${manifest}
unlink ${manifest}

echo use the following token to log in in the k8s dashboard
cat $KUBECONFIG | awk '/ token:/ {print $2}'

