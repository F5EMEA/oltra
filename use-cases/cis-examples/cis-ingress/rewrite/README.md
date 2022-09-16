# Rewrite Examples

In this section we provide 2 Rewrite deployment examples. The firt example rewrites the root path and the second the URL. 

- [AppRoot-Rewrite](#AppRoot-Rewrite)
- [URL-Rewrite](#URL-Rewrite)

## AppRoot-Rewrite
In the following example we deploy an Ingress resource with rewrite-app-root annotation that will redirect any traffic for the root path `/` to `/approot1`.

Eg: rewrite-app-root.yml
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-app-root
  annotations:
    virtual-server.f5.com/ip: 10.1.10.50
    virtual-server.f5.com/rewrite-app-root: rewrite1.f5demo.local=/approot1,rewrite2.f5demo.local=/approot2
spec:
  ingressClassName: f5
  rules:
    - host: rewrite1.f5demo.local
      http:
        paths:
          - backend:
              service:
                name: app1-svc
                port:
                  number: 80
            path: /approot1
            pathType: Prefix
    - host: rewrite2.f5demo.local
      http:
        paths:
          - backend:
              service:
                name: app2-svc
                port:
                  number: 80
            path: /approot2
            pathType: Prefix
```

Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Change the working directory to `rewrite`.
```
cd ~/oltra/use-cases/cis-examples/cis-ingress/rewrite
```

Create the Ingress resource.
```
kubectl apply -f rewrite-app-root.yml
```


Confirm that the Ingress is deployed correctly. Run the describe command to get more information on the ingress.
```
kubectl describe ingress rewrite-app-root

------------------------   OUTPUT   ------------------------
Name:             rewrite-app-root
Labels:           <none>
Namespace:        default
Address:          10.1.10.50
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host                   Path  Backends
  ----                   ----  --------
  rewrite1.f5demo.local  
                         /approot1   app1-svc:80 (10.244.140.122:8080,10.244.196.145:8080)
  rewrite2.f5demo.local  
                         /approot2   app2-svc:80 (10.244.140.116:8080,10.244.196.165:8080)
Annotations:             virtual-server.f5.com/ip: 10.1.10.50
                         virtual-server.f5.com/rewrite-app-root: rewrite1.f5demo.local=/approot1,rewrite2.f5demo.local=/approot2
Events:
  Type    Reason              Age   From            Message
  ----    ------              ----  ----            -------
  Normal  ResourceConfigured  5s    k8s-bigip-ctlr  Created a ResourceConfig ingress_10-1-10-50_80 for the Ingress.
------------------------------------------------------------
```

Try accessing the service.

```
curl -v http://rewrite1.f5demo.local/ --resolve rewrite1.f5demo.local:80:10.1.10.50
curl -v http://rewrite2.f5demo.local/ --resolve rewrite2.f5demo.local:80:10.1.10.50
```

The output should be similar to the following:

```cmd
* Added rewrite1.f5demo.local:80:10.1.10.50 to DNS cache
* Hostname rewrite1.f5demo.local was found in DNS cache
*   Trying 10.1.10.50...
* TCP_NODELAY set
* Connected to rewrite1.f5demo.local (10.1.10.50) port 80 (#0)
> GET / HTTP/1.1
> Host: rewrite1.f5demo.local
> User-Agent: curl/7.58.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 302 Moved Temporarily                                   <===== 302 Response
< Location: /approot1                                              <===== Location set as per the "rewrite-app-root" annotation 
< Server: BigIP                                                    <===== Response from BIGIP
* HTTP/1.0 connection set to keep alive!
< Connection: Keep-Alive
< Content-Length: 0
< 
* Connection #0 to host rewrite1.f5demo.local left intact

```

> The location header has been set to `/approot1`.
>Similarly if accessing the service `rewrite2.f5demo.local` the location will be set to `approot2`


***Clean up the environment (Optional)***
```
kubectl delete -f basic-ingress.yml
```

## URL-Rewrite
In the following example we deploy an Ingress resource that rewrites the URL from `lab.f5demo.local/mylab` to `laboratory.f5demo.local/mylaboratory`.

Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Change the working directory to `rewrite`.
```
cd ~/oltra/use-cases/cis-examples/cis-ingress/rewrite
```

Create the Ingress resource.
```
kubectl apply -f url-rewrite-ingress.yml
```


Confirm that the Ingress is deployed correctly. Run the describe command to get more information on the ingress.
```
kubectl describe ingress url-rewrite-ingress

------------------------   OUTPUT   ------------------------
Name:             url-rewrite-ingress
Labels:           <none>
Namespace:        default
Address:          10.1.10.50
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host              Path  Backends
  ----              ----  --------
  lab.f5demo.local  
                    /mylab   echo-svc:80 (10.244.140.93:80,10.244.196.135:80)
Annotations:        virtual-server.f5.com/ip: 10.1.10.50
                    virtual-server.f5.com/rewrite-target-url: lab.f5demo.local/mylab=laboratory.f5demo.local/mylaboratory
Events:
  Type    Reason              Age   From            Message
  ----    ------              ----  ----            -------
  Normal  ResourceConfigured  22s   k8s-bigip-ctlr  Created a ResourceConfig ingress_10-1-10-50_80 for the Ingress.
------------------------------------------------------------
```

Try accessing the service.
```
curl http://lab.f5demo.local/mylab --resolve lab.f5demo.local:80:10.1.10.50
```

The output should be similar to the following:

```cmd
{
    "Server Name": "laboratory.f5demo.local",                   <==== Request Hostname as seen by the backend server
    "Server Address": "10.244.140.93",
    "Server Port": "80",
    "Request Method": "GET",
    "Request URI": "/mylaboratory",                             <==== Request URL as seen by the backend server
    "Query String": "",
    "Headers": [{"host":"laboratory.f5demo.local","user-agent":"curl\/7.58.0","accept":"*\/*"}],
    "Remote Address": "10.1.20.5",
    "Remote Port": "59360",
    "Timestamp": "1657605359",
    "Data": "0"
}
```
> Note that the Hostname and Path that was send on the backend application has been changed as per the rewrite annotation.


***Clean up the environment (Optional)***
```
kubectl delete -f url-rewrite-ingress.yml
```