# Basic-Ingress
In the following example we deploy a basic ingress resource for a single K8s service.

Eg: basic-ingress.yml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: basic-ingress
  annotations:
    virtual-server.f5.com/ip: "10.1.10.49"
    virtual-server.f5.com/balance: "round-robin"
    virtual-server.f5.com/http-port: "80"
spec:
  ingressClassName: f5
  defaultBackend:
    service:
      name: echo-svc
      port:
        number: 80
```

Change the working directory to `basic-ingress`.
```
cd ~/oltra/use-cases/cis-examples/cis-ingress/basic-ingress
```

Create the Ingress resource.
```
kubectl apply -f basic-ingress.yml
```

Confirm that the Ingress is deployed correctly. Run the describe command to get more information on the ingress  

```
kubectl describe ingress basic-ingress

------------------------   OUTPUT   ------------------------

Name:             basic-ingress
Labels:           <none>
Namespace:        default
Address:          10.1.10.49
Default backend:  echo-svc:80 (10.244.140.87:80,10.244.196.184:80)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           *     echo-svc:80 (10.244.140.87:80,10.244.196.184:80)  

Annotations:  virtual-server.f5.com/balance: round-robin
              virtual-server.f5.com/http-port: 80
              virtual-server.f5.com/ip: 10.1.10.49
Events:
  Type    Reason              Age                From            Message
  ----    ------              ----               ----            -------
  Normal  ResourceConfigured  21s (x2 over 21s)  k8s-bigip-ctlr  Created a ResourceConfig ingress_10-1-10-49_80 for the Ingress

------------------------------------------------------------
```

Notice that:
-  Under the **Events** section it includes the message `Created a ResourceConfig ingress_10-1-10-49_80 for the Ingress`
-  Under the **Rules section** the value of **Host** and **Path** is configured as `*` 


Access the service as per the examples below. 

```
curl http://10.1.10.49
curl http://10.1.10.49/test.php
curl http://test.f5demo.local --resolve test.f5demo.local:80:10.1.10.49
```

In all cases you should see similar output:
```cmd
$ curl http://test.f5demo.local --resolve test.f5demo.local:80:10.1.10.49

{
    "Server Name": "test.f5demo.local",
    "Server Address": "10.244.140.87",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/",
    "Query String": "",
    "Headers": [{"host":"test.f5demo.local","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "52656",
    "Timestamp": "1657553826",
    "Data": "0"
}
```
