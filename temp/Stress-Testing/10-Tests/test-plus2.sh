echo "***** Changing SAME Ingress Resource **********"

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
