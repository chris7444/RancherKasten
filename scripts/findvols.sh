prog=$(basename $0)
if [[ "$1" == "" ]]
then
  echo usage: $prog pvc
  echo " finds clones of the specified PVC"
  exit
fi

pvc=$1
vols=$(ssh nimble vol --list --folder=prod | awk '/^pvc/ { print $1 }')
for vol in $vols
do
   pvol=$(ssh nimble vol --info $vol | awk  '/Parent volume:/ {print $3}')
   if [[ $pvol == $pvc ]]
   then
     echo $vol
   fi
done
echo $pvc
