echo "Deploying 80 ingress resrouces"

kubectl apply -f ingress-community-80.yaml
sleep 5
echo "Completed deploying ingress resources"
sleep 1
echo " ****************   Starting Test **************** "

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

echo " ****************   Completed Test **************** "
sleep 5

echo "****************  Starting Test  ****************"

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

echo " ****************   Completed Test **************** "


sleep 5

echo "****************  Starting Test  ****************"

echo "******* Adding/Removing Ingress Other Services **********"

x=1
while [ $x -le 2 ]
do
  kubectl delete -f ingress-community-10.yaml
  sleep 20
  kubectl apply -f ingress-community-10.yaml
  sleep 20
  x=$(( $x + 1 ))
done

echo " ****************   Completed Test **************** "
