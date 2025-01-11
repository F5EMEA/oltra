## These instructions are for an ubuntu machine

1. Run the following command to install k3s
```
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr=10.221.0.0/16 --node-ip=10.1.20.21 --disable-network-policy --disable=traefik" sh -
```
It should install k3s (latest) but disable traefik and flannel
Note: We are using calico.


2. Deploy calico by running the following command:
```
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl apply -f calico.yam
```
Note: Check calico documentation to see what is the latest calico you should use 