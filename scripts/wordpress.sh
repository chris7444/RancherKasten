. ~/proxy.rc
if (( $# != 1 ))
then
  echo "usage: $0 password"
  echo '  deploy opencart with the specified password'
  exit
fi
kubectl get ns wordpress >/dev/null 2>&1 || kubectl create ns wordpress
helm install wordpress bitnami/wordpress -n wordpress --set wordpressPassword="$1" --set wordpressUsername=admin
