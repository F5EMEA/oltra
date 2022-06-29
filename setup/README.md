# F5 Ingress

# Deploy CIS
Pre-requisites
1. Change the username/password for BIGIP on bigip-secret.yml
2. On files cis-ctlr-crd.yml and cis-ctlr-ingress.yml change the IP address to match your BIGIP  "--bigip-url=192.168.3.103"

kubectl create -f 1-CIS
kubectl create -f 2-IPAM



# Deploy Prometheus

kubectl create -f /home/kostas/ingress/kube-prometheus/setup
kubectl apply -f /home/kostas/ingress/kube-prometheus/