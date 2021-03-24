#!/bin/bash
#
# Here is how one can configure the K10 multi-Cluster manager
#   in this example, the Kasten running on the cluster cns is the primary instance
#                    the Kasten running on the cluster clh is the secondary instance
#
cat <<EOF
cd /tmp
wget https://github.com/kastenhq/external-tools/releases/download/3.0.10/k10multicluster_3.0.10_linux_amd64
mv ./k10multicluster_3.0.10_linux_amd64 ./k10multicluster
chmod +x k10multicluster
KUBECONFIG=~/.svtrancher/kube_config.cns \
     ./k10multicluster setup-primary --name cns
KUBECONFIG=~/.svtrancher/kube_config.cns \
     ./k10multicluster bootstrap \
     --primary-name=cns \
     --secondary-kubeconfig=/home/chris/.svtrancher/kube_config.clh \
     --secondary-name=clh \
     --secondary-cluster-ingress=https://kasten.clh.k8s.org/k10 \
     --secondary-cluster-ingress-tls-insecure=true \
EOF

