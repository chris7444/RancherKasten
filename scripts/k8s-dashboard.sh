#!/bin/bash
#
# site specific stuff
#
. ~/proxy.rc
cluster=$(kubectl config current-context)
if [[ $? != 0 ]]
then
   echo Make sure KUBECONFIG points to a valid kubeconfig file
fi
domain=k8s.org

#
# Deploy the dashboard
#
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml

#
# Deploy the Ingress
#
manifest=$(mktemp)
cat <<EOF >${manifest}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
  name: dashboard
  namespace: kubernetes-dashboard
spec:
  rules:
  - host: dashboard.${cluster}.${domain}
    http:
      paths:
      - backend:
          serviceName: kubernetes-dashboard
          servicePort: 443
        path: /
        pathType: Prefix
EOF
kubectl apply -f ${manifest}
unlink ${manifest}

echo use the following token to log in in the k8s dashboard
cat ~/.svtrancher/kube_config.clh | awk '/ token:/ {print $2}'
