# FQDN-Based-Routing
In the following example we deploy an Ingress resource that routes based on FQDNs:

- **fqdn1.f5demo.local => app1-svc**
- **fqdn2.f5demo.local => app2-svc**


Eg: host-routing.yml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: fqdn-based-routing
 annotations:
  virtual-server.f5.com/ip: "10.1.10.50"
  virtual-server.f5.com/balance: "round-robin"
  virtual-server.f5.com/http-port: "80"
spec:
 ingressClassName: f5
 rules:
 - host: fqdn1.f5demo.local
   http:
     paths:
       - path: /
         pathType: Prefix
         backend:
           service:
             name: app1-svc
             port:
               number: 80
 - host: fqdn2.f5demo.local
   http:
     paths:
       - path: /
         pathType: Prefix
         backend:
           service:
             name: app2-svc
             port:
               number: 80

```

Change the working directory to `host-routing`.
```
cd ~/oltra/examples/cis/cis-ingress/host-routing
```

Create the Ingress resource.
```
kubectl apply -f host-routing.yml
```

Confirm that the Ingress is deployed correctly. Run the describe command to get more information on the ingress.
```
kubectl describe ingress fqdn-based-routing

------------------------   OUTPUT   ------------------------
Name:             fqdn-based-routing
Labels:           <none>
Namespace:        default
Address:          10.1.10.50
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host                Path  Backends
  ----                ----  --------
  fqdn1.f5demo.local  
                      /   app1-svc:80 (10.244.140.91:8080,10.244.196.135:8080)
  fqdn2.f5demo.local  
                      /   app2-svc:80 (10.244.140.66:8080,10.244.196.148:8080)

Annotations:          virtual-server.f5.com/balance: round-robin
                      virtual-server.f5.com/http-port: 80
                      virtual-server.f5.com/ip: 10.1.10.50
Events:
  Type    Reason              Age   From            Message
  ----    ------              ----  ----            -------
  Normal  ResourceConfigured  5s    k8s-bigip-ctlr  Created a ResourceConfig ingress_10-1-10-50_80 for the Ingress.
------------------------------------------------------------
```

> Notice that the value of Host is now defined ("fqdn1.f5demo.local" / "fqdn2.f5demo.local").


Try accessing the service with the IP address assigned for the ingress as per the example below. 
```
curl http://10.1.10.50
```

You should see a reset connection as it didnt match the configured Host Header.
`curl: (56) Recv failure: Connection reset by peer`

Try again with either of the two following options
```
curl http://fqdn1.f5demo.local/ --resolve fqdn1.f5demo.local:80:10.1.10.50
curl http://fqdn2.f5demo.local/ --resolve fqdn2.f5demo.local:80:10.1.10.50
```

In both cases you should see that similar output but from different backend pods (app1 and app2 pods):

```cmd
~/oltra/examples/cis/cis-ingress/fanout$ curl http://fqdn2.f5demo.local/ --resolve fqdn2.f5demo.local:80:10.1.10.50

Server address: 10.244.140.66:8080
Server name: app2-78c95bccb5-jvfnr              <======  app2 pods
Date: 11/Jul/2022:15:54:39 +0000
URI: /      
Request ID: b07b6622cf0573aecd412da90f341ca9
```

