
echo " ****************   Starting Test 1 **************** "

echo "  **********Deploying 80 ingress resources ********"
sleep 1
kubectl apply -f ingress-oss-80.yml
echo "  **** Completed deploying ingress resources  ******"
echo " ****************   Completed Test 1 **************** "

echo " ****************************************************"
echo " *****        sleeping for 120 seconds         ******"
echo " ****************************************************"

sleep 120

echo " ****************   Starting Test 2 **************** "

echo "Changing other Ingress Resourcesß"

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
echo " ****************************************************"
echo " *****        sleeping for 120 seconds         ******"
echo " ****************************************************"

sleep 120
echo "****************  Starting Test 3 ****************"

echo "******* Changing SAME Ingress Resource **********"

x=1
while [ $x -le 3 ]
do
  kubectl scale deployment echo --replicas=14
  sleep 10
  kubectl scale deployment echo --replicas=11
  sleep 10
  kubectl scale deployment echo --replicas=12
  sleep 10
  kubectl scale deployment echo --replicas=8
  sleep 10
  kubectl scale deployment echo --replicas=14
  sleep 10
  x=$(( $x + 1 ))
done

echo " ****************   Completed Test 3 **************** "


echo " ****************************************************"
echo " *****        sleeping for 120 seconds         ******"
echo " ****************************************************"

sleep 120

echo "****************  Starting Test 4 ****************"

echo "******* Adding/Removing Ingress Other Services **********"

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

