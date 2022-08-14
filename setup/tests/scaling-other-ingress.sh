
echo " ****************   Starting Test 2 **************** "

echo "Changing other Ingress Resourcesß"
sleep 1
x=1
while [ $x -le 5 ]
do
  kubectl scale deployment myapp-1 --replicas=5
  sleep 1
  kubectl scale deployment myapp-2 --replicas=5
  sleep 1
  kubectl scale deployment myapp-3 --replicas=5
  sleep 1
  kubectl scale deployment myapp-1 --replicas=2
  sleep 1
  kubectl scale deployment myapp-2 --replicas=2
  sleep 1
  kubectl scale deployment myapp-3 --replicas=2
  sleep 1
  x=$(( $x + 1 ))
done

echo " ****************   Completed Test 2 **************** "