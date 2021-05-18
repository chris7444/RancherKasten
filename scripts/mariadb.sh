values=$(mktemp)
cat <<EOF > ${values}
auth:
  rootPassword: admin
EOF
sudo apt install -y mysql-client
kubectl create ns mariadb 2>/dev/null
helm repo add bitnami https://charts.bitnami.com/bitnami
if ! helm ls -q -n mariadb | grep -q ^mydb
then
  echo installing mariadb
  helm install -f ${values} -n mariadb mydb bitnami/mariadb
else
  echo mariadb already installed
fi
rm ${values}
cd ~
[ -d test_db ] || git clone https://github.com/datacharmer/test_db
cd test_db
#kubectl -n mariadb port-forward service/mydb-mariadb 3306:3306 &
