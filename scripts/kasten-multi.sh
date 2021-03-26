#!/bin/bash
#
# Here is how one can configure the K10 multi-Cluster manager
#
cat <<EOF >/dev/null
cd /tmp
wget https://github.com/kastenhq/external-tools/releases/download/3.0.10/k10multicluster_3.0.10_linux_amd64
sudo mv ./k10multicluster_3.0.10_linux_amd64 /usr/local/sbin/k10multicluster
sudo chmod +x /usr/local/sbin/k10multicluster
KUBECONFIG=~/.svtrancher/kube_config.cns \
     k10multicluster setup-primary --name cns
EOF

if [[ $# > 1 ]]
then
  echo usage: $(basename $0) [remove]
  echo ' Join (or remove) Kasten on this cluster to (from) the primary Kasten instance running on the CNS clusterr'
  exit 0
fi

domain=k8s.org
cluster=$(kubectl config current-context)
if [[ $? != 0 ]]
then
  echo Please configure KUBECONFIG
  exit 1
fi

if [[ $1 == "remove" ]]
then
  k10multicluster remove \
    --primary-kubeconfig=/home/chris/.svtrancher/kube_config.cns \
    --primary-name=cns \
    --secondary-name=${cluster}
else
  k10multicluster bootstrap \
    --primary-kubeconfig=/home/chris/.svtrancher/kube_config.cns \
    --primary-name=cns \
    --secondary-name=${cluster} \
    --secondary-cluster-ingress=https://kasten.${cluster}.${domain}/k10 \
    --secondary-cluster-ingress-tls-insecure=true 
fi

