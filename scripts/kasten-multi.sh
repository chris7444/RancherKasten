#!/bin/bash
#
# Here is how one can configure the K10 multi-Cluster manager
#
function usage ()
{
  echo usage: $(basename $0) 'add|remove'
  echo ' add: Join Kasten on this cluster to the primary Kasten instance running on the CNS cluster'
  echo ' remove: remove Kasten on this cluster from the primary Kasten instance running on the CNS cluster'
}

cat <<EOF >/dev/null
cd /tmp
wget https://github.com/kastenhq/external-tools/releases/download/3.0.10/k10multicluster_3.0.10_linux_amd64
sudo mv ./k10multicluster_3.0.10_linux_amd64 /usr/local/sbin/k10multicluster
sudo chmod +x /usr/local/sbin/k10multicluster
KUBECONFIG=~/.svtrancher/kube_config.cns \
     k10multicluster setup-primary --name cns
EOF

if [[ $# != 1 ]]
then
  usage
  exit 0
fi

domain=${MY_DOMAIN:-hpe.org}
cluster=$(kubectl config current-context)
if [[ $? != 0 ]]
then
  echo Please configure KUBECONFIG
  exit 1
fi

case $1 in
  "remove")
    echo remove
  ;;
  "add")
    echo add
  ;;
  *)
    usage
    exit 1
esac

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

