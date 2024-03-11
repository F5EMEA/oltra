# Rewrite Examples

In this section we provide 2 rewrite examples. One for AppRoot rewrite and another for URI Path rewrite.

- [AppRoot rewrite (rewriteAppRoot)](#approot-rewrite)
- [URI Path rewrite (rewrite)](#uri-path-rewrite)

> *To run the demos, use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how.*

## AppRoot rewrite
Redirecting the application to specific path when request made with root path "/".

Eg: approot.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: approot-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.61"
  rewriteAppRoot: /home
  host: approot.f5k8s.net
  pools:
    - path: /
      service: app1-svc
      servicePort: 8080
```

Change the working directory to `Rewrite`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/Rewrite
```
> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the CRD resource.
```
kubectl apply -f approot.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs approot-vs
```

Access the service using curl. 
```
curl -v http://approot.f5k8s.net/
```

You should receive a 302 redirect from BIGIP with Location Header set as `/home`. The output should be similar to:
```
* Added approot.f5k8s.net:80:10.1.10.61 to DNS cache
* Hostname approot.f5k8s.net was found in DNS cache
*   Trying 10.1.10.61...
* TCP_NODELAY set
* Connected to approot.f5k8s.net (10.1.10.61) port 80 (#0)
> GET / HTTP/1.1
> Host: approot.f5k8s.net
> User-Agent: curl/7.58.0
> Accept: */*
> 
* HTTP 1.0, assume close after body
< HTTP/1.0 302 Moved Temporarily
< Location: /home                           <======== Location Header
< Server: BigIP
* HTTP/1.0 connection set to keep alive!
< Connection: Keep-Alive
< Content-Length: 0
```

***Clean up the environment (Optional)***
```
kubectl delete -f approot-vs
```

## URI Path rewrite
Rewriting the path in HTTP Header of a request before submitting to the pool

Eg: rewrite.yml
```yml
apiVersion: "cis.f5.com/v1"
kind: VirtualServer
metadata:
  name: rewrite-vs
  labels:
    f5cr: "true"
spec:
  virtualServerAddress: "10.1.10.62"
  host: rewrite.f5k8s.net
  pools:
    - path: /lab
      service: svc-1
      servicePort: 8080
      rewrite: /laboratory
    - path: /lib
      service: svc-2
      servicePort: 8080
      rewrite: /library
```

Change the working directory to `Rewrite`.
```
cd ~/oltra/use-cases/cis-examples/cis-crd/VirtualServer/Rewrite
```

> **Note:** Verify that the backend service is working. Otherwise go to `oltra/setup/apps` and deploy the service.

Create the CRD resource.
```
kubectl apply -f rewrite.yml
```

Confirm that the VS CRD is deployed correctly. You should see `Ok` under the Status column for the VirtualServer that was just deployed.
```
kubectl get f5-vs rewrite-vs
```

Access the service using curl. 
```
curl http://rewrite.f5k8s.net/lab
curl http://rewrite.f5k8s.net/lib
```

Note that the paths are rewritten from `/lib` to `/library` and from `/lab` to `/laboratory`.  The output should be similar to:
```
Server address: 10.244.140.109:8080
Server name: app2-78c95bccb5-jvfnr
Date: 12/Jul/2022:14:12:25 +0000
URI: /library
Request ID: 0495d6a17797ea9776120d5f4af10c1a
```

***Clean up the environment (Optional)***
```
kubectl delete -f rewrite.yml
```