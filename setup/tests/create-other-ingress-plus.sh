while [ 1 -eq 1 ]
do
  kubectl delete -f ingress-plus-10.yaml
  sleep 20
  kubectl apply -f ingress-plus-10.yaml
  sleep 20
done