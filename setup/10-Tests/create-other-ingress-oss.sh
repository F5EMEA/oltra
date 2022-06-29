
echo "****************  Starting Test 4 ****************"

echo "******* Adding/Removing Ingress Other Services **********"
sleep 2
x=1
while [ $x -le 2 ]
do
  kubectl delete -f ingress-oss-10.yml
  sleep 30
  kubectl apply -f ingress-oss-10.yml
  sleep 30
  x=$(( $x + 1 ))
done

echo " ****************   Completed Test 4 **************** "

