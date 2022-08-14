echo "****************  Starting Test 3 ****************"

echo "******* Changing SAME Ingress Resource **********"
sleep 1
x=1
while [ $x -le 2 ]
do
  kubectl scale deployment/echo --replicas=14
  echo "scale 8 -> 14"
  echo "sleep 30"
  sleep 30
  kubectl scale deployment/echo --replicas=11
  echo "scale 14 -> 11"
  echo "sleep 30"
  sleep 30  
  kubectl scale deployment/echo --replicas=9
  echo "scale 11 -> 9"
  echo "sleep 30"
  sleep 30  
  kubectl scale deployment/echo --replicas=6
  echo "scale 9 -> 6"
  echo "sleep 30"
  sleep 30  
  kubectl scale deployment/echo --replicas=4
  echo "scale 6 -> 4"
  echo "sleep 30"
  sleep 30  
  x=$(( $x + 1 ))
done

echo " ****************   Completed Test 3 **************** "
