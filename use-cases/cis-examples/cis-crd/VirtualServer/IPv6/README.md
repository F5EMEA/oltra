# Custom Virtual Server Name

This section demonstrates the option to configure an IPv6 virtual server 

Eg: ipv6-virtual-server.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: ipv6-vs
  labels:
    f5cr: "true"
spec:
  host: ipv6.f5demo.local
  virtualServerAddress: "2002:0:0:0:10:0:0:2"
  virtualServerName: "ipv6-vs"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
```

Create the VS CRD resource. 
```
kubectl apply -f ipv6-virtual-server.yml
```
CIS will create a Virtual Server on BIG-IP with VIP "2002:0:0:0:10:0:0:".   


Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```
