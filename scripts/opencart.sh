#!/bin/bash
#
# Site specific stuff
#
. ~/proxy.rc
cluster=$(kubectl config current-context)
if [[ $? != 0 ]]
then
   echo Make sure KUBECONFIG points to a valid kubeconfig file
fi
domain=k8s.org
if [[ "${MY_REGISTRY}" == "" ]]
then
  flag=""
else
  flag="--set global.imageRegistry=${MY_REGISTRY} --version=10.0.5"
  echo using registry ${MY_REGISTRY}
fi

#
# Check Syntax
#
if (( $# != 1 ))
then
  echo "usage: $0 password"
  echo '  deploy opencart with the specified password'
  exit
fi

#
# Create the Namespace
#
kubectl get ns opencart >/dev/null 2>&1 || kubectl create ns opencart

#
# Deploy opencart
#
iamthere=$(helm ls -n opencart  -f '^opencart$' -q)
if [[ "$iamthere" != "opencart" ]]
then
  helm install opencart local-bitnami/opencart -n opencart \
        --set opencartHost=opencart.${cluster}.${domain} \
        --set opencartPassword="$1" \
        --set opencartUsername=admin ${flag} \
        --set ingress.enabled=true \
        --set ingress.hostname=opencart.${cluster}.${domain} \
        --set service.type=NodePort \
        --wait
else
  echo helm chart already installed
fi

#
# Deploy the Ingress
#
manifest=$(mktemp)
cat <<EOF >${manifest}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: opencart
  namespace: opencart
spec:
  rules:
  - host: opencart.${cluster}.${domain}
    http:
      paths:
      - backend:
          serviceName: opencart
          servicePort: 80
        path: /
        pathType: Prefix
EOF
#kubectl apply -f ${manifest}
unlink ${manifest}
#kubectl get ingress opencart -n opencart
