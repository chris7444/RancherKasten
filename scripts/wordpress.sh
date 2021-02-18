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
domain=hpe.org

#
# Check syntax
#
if (( $# != 1 ))
then
  echo "usage: $0 password"
  echo '  deploy wordpress with the specified password'
  exit
fi

#
# Create the Namespace
#
kubectl get ns wordpress >/dev/null 2>&1 || kubectl create ns wordpress

#
# Deploy wordpress
#
iamthere=$(helm ls -n wordpress  -f '^wordpress$' -q)
if [[ $iamthere != "wordpress" ]]
then
  helm install wordpress bitnami/wordpress -n wordpress --set wordpressPassword="$1" --set wordpressUsername=admin
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
  name: wordpress
  namespace: wordpress
spec:
  rules:
  - host: wordpress.${cluster}.${domain}
    http:
      paths:
      - backend:
          serviceName: wordpress
          servicePort: 80
        path: /
        pathType: Prefix
EOF
kubectl apply -f ${manifest}
unlink ${manifest}
kubectl get ingress wordpress -n wordpress
