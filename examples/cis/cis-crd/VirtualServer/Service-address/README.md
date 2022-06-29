# Virtual Service Address
 
Service address definition allows you to add a number of properties to your (virtual) server address.This section demonstrates the option to configure virtual address with service address.


Eg: service-address-vs.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: service-address-vs
  labels:
    f5cr: "true"
spec:
  host: service.f5demo.local
  virtualServerAddress: "10.1.10.99"
  virtualServerName: "service-address-vs"
  pools:
  - path: /
    service: echo-svc
    servicePort: 80
  serviceAddress:
  - icmpEcho: "enable"
    arpEnabled: true
    routeAdvertisement: "all"

```

Create the VirtualServerCRD resource.
```
kubectl apply -f service-address-vs.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get vs 
```