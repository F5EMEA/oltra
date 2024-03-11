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
  host: service.f5k8s.net
  virtualServerAddress: "10.1.10.67"
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

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*


Change the working directory to `Service-address`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/Service-address
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the VirtualServer resource. 
```
kubectl apply -f service-address.yml
```

Confirm that the VirtualServer resource is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs service-address-vs
```

***Clean up the environment (Optional)***
```
kubectl delete -f service-address.yml
```