# FanOut/Path-Based-Routing
In the following example we deploy an Ingress resource that routes based on the URL Path:

- **fanout.f5demo.local/__app2__ => app2-svc**
- **fanout.f5demo.local/__app1__ => app1-svc**


Eg: fanout.yml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fanout
  annotations:
    virtual-server.f5.com/ip: "10.1.10.50"
    virtual-server.f5.com/balance: "round-robin"
spec:
  ingressClassName: f5
  rules:
  - host: fanout.f5demo.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-svc
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-svc
            port:
              number: 80
```

Change the working directory to `fanout`
```
cd ~/oltra/use-cases/cis-examples/cis-ingress/fanout
```

Create the Ingress resource.
```
kubectl apply -f fanout.yml
```

Confirm that the Ingress is deployed correctly. Run the describe command to get more information on the ingress.
```
kubectl describe ingress fanout

------------------------   OUTPUT   ------------------------
Name:             fanout
Labels:           <none>
Namespace:        default
Address:          10.1.10.50
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  fanout.f5demo.local  
                       /app1   app1-svc:80 (10.244.140.91:8080,10.244.196.135:8080)
                       /app2   app2-svc:80 (10.244.140.66:8080,10.244.196.148:8080)

Annotations:           virtual-server.f5.com/balance: round-robin
                       virtual-server.f5.com/ip: 10.1.10.50
Events:
  Type    Reason              Age   From            Message
  ----    ------              ----  ----            -------
  Normal  ResourceConfigured  8s    k8s-bigip-ctlr  Created a ResourceConfig ingress_10-1-10-50_80 for the Ingress.
------------------------------------------------------------
```

Notice on **Rules** section the output value of Host is now defined as "**fanout.f5demo.local**" and on the Path level there are 2 entries; __app1__ that points to `app1-svc` and __/app2__ that points to `app2-svc`.

Try accessing the service on a path that has not been defined on the Ingress resource like the example below.

```
curl http://fanout.f5demo.local/test/index.php --resolve fanout.f5demo.local:80:10.1.10.50
```
You should see a reset connection as it didnt match the configured Path value.
`curl: (56) Recv failure: Connection reset by peer`


Try again with either of the following options
```
curl http://fanout.f5demo.local/app1/index.php --resolve fanout.f5demo.local:80:10.1.10.50
curl http://fanout.f5demo.local/app2/index.php --resolve fanout.f5demo.local:80:10.1.10.50
curl http://fanout.f5demo.local/app1 --resolve fanout.f5demo.local:80:10.1.10.50
curl http://fanout.f5demo.local/app2 --resolve fanout.f5demo.local:80:10.1.10.50
```

In all cases you should see similar outputs but from different backend pods (__app1__ and __app2__ pods) depending on the path.

```cmd
~/oltra/use-cases/cis-examples/cis-ingress/fanout$ curl http://fanout.f5demo.local/app2 --resolve fanout.f5demo.local:80:10.1.10.50

Server address: 10.244.140.66:8080
Server name: app2-78c95bccb5-jvfnr              <======  app2 pods
Date: 11/Jul/2022:15:54:39 +0000
URI: /app2      
Request ID: b07b6622cf0573aecd412da90f341ca9
```

